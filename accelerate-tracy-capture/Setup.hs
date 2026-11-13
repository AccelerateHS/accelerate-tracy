{-# LANGUAGE CPP        #-}
{-# LANGUAGE LambdaCase #-}
{-# OPTIONS -Wall -Wcompat #-}
module Main (main) where

import Control.Monad (when)
import Distribution.PackageDescription (PackageDescription)
import Distribution.PackageDescription qualified as PkgDesc
import Distribution.Simple qualified as Simple
import Distribution.Simple.BuildPaths qualified as BuildPaths
import Distribution.Simple.InstallDirs (CopyDest, InstallDirs)
import Distribution.Simple.InstallDirs qualified as InstallDirs
import Distribution.Simple.LocalBuildInfo (LocalBuildInfo)
import Distribution.Simple.LocalBuildInfo qualified as LocalBuildInfo
import Distribution.Simple.Setup qualified as Setup
import Distribution.Simple.Utils qualified as Utils
import Distribution.System qualified as System
import Distribution.Verbosity (Verbosity)
import Distribution.Verbosity qualified as Verbosity
import System.Directory qualified as Dir
import System.FilePath ((<.>), (</>))

{-------------------------------------------------------------------------------
  Configuration
-------------------------------------------------------------------------------}

-- | Tracy executable name
exeName :: String
exeName = "tracy-capture"

-- | Source directory in @cbits/tracy@ repository
exeSourceDir :: String
exeSourceDir = "capture"

-- | CMake options to pass when generating the project buildsystem
cmakeGenerateOpts :: [String]
cmakeGenerateOpts =
  [ "-DCMAKE_BUILD_TYPE=Release"
  , "-DLEGACY=1"  -- Build with X11 instead of Wayland
  ]

-- | CMake options to pass when building the project
cmakeBuildOpts :: [String]
cmakeBuildOpts =
  [ "--config", "Release"
  , "-j", "2"
  ]

{-------------------------------------------------------------------------------
  Implementation
-------------------------------------------------------------------------------}

main :: IO ()
main =
  Simple.defaultMainWithHooks Simple.simpleUserHooks
    { Simple.postConf  = postConfHook
    , Simple.postBuild = postBuildHook
    , Simple.postCopy  = postCopyHook
    , Simple.postInst  = postInstHook
    }

-- | Post-configuration hook
--
-- When developing locally, Cabal does not copy/install the Tracy executable.
-- This hook generates module @PathsBuild_accelerate_tracy_capture@ that exposes
-- the build directory so that the Tracy executable can be found in that case.
postConfHook
  :: Simple.Args
  -> Setup.ConfigFlags
  -> PackageDescription
  -> LocalBuildInfo
  -> IO ()
postConfHook args configFlags pkgDesc localBuildInfo = do
  Simple.postConf Simple.simpleUserHooks args configFlags pkgDesc localBuildInfo
  writeBuildPathsModule verbosity pkgDesc localBuildInfo
  where
    verbosity :: Verbosity
    verbosity
      = Setup.fromFlagOrDefault Verbosity.normal
      $ Setup.configVerbosity configFlags

writeBuildPathsModule
  :: Verbosity
  -> PackageDescription
  -> LocalBuildInfo
  -> IO ()
writeBuildPathsModule verbosity pkgDesc localBuildInfo = do
  buildDir <- Dir.makeAbsolute $ getBuildDir localBuildInfo
  setupMessage "Generating PathsBuild_accelerate_tracy_capture"
  info $ "Module directory: " ++ modDir
  info $ "Build directory: " ++ buildDir
  Utils.createDirectoryIfMissingVerbose verbosity True modDir
  Utils.rewriteFileEx verbosity modFile $ unlines
    [ "module PathsBuild_accelerate_tracy_capture (foreignTracyBuildDir) where"
    , "foreignTracyBuildDir :: FilePath"
    , "foreignTracyBuildDir = " ++ show buildDir
    ]
  where
    modDir, modFile :: FilePath
    modDir  = getModulesDir localBuildInfo
    modFile = modDir </> "PathsBuild_accelerate_tracy_capture.hs"

    setupMessage, info :: String -> IO ()
    setupMessage msg =
      Utils.setupMessage verbosity msg (PkgDesc.package pkgDesc)
    info = Utils.infoNoWrap verbosity

-- | Post-build hook
--
-- This hook builds the Tracy executable.  When developing locally, Cabal does
-- not copy/install the Tracy executable.  When building as a dependency, the
-- Tracy executable must be copied to the staging directory in order to be
-- installed into the Cabal Store.  This is done in 'postCopyHook'.
postBuildHook
  :: Simple.Args
  -> Setup.BuildFlags
  -> PackageDescription
  -> LocalBuildInfo
  -> IO ()
postBuildHook args buildFlags pkgDesc localBuildInfo = do
  Simple.postBuild Simple.simpleUserHooks args buildFlags pkgDesc localBuildInfo
  buildTracyExe verbosity pkgDesc localBuildInfo
  where
    verbosity :: Verbosity
    verbosity
      = Setup.fromFlagOrDefault Verbosity.normal
      $ Setup.buildVerbosity buildFlags

buildTracyExe
  :: Verbosity
  -> PackageDescription
  -> LocalBuildInfo
  -> IO ()
buildTracyExe verbosity pkgDesc localBuildInfo =
  case LocalBuildInfo.hostPlatform localBuildInfo of
    System.Platform _arch System.Windows ->
      -- TODO build Tracy executables on Windows
      -- <https://github.com/AccelerateHS/accelerate-tracy/issues/2>
      setupMessage $ "Not building Tracy executable on Windows: " ++ exeName
    _platform -> do
      -- Determine if the executable needs to be build, based on existence and
      -- modification times
      sourceNewer <- Dir.doesFileExist buildExe >>= \case
        False -> return True
        True  -> do
          sourceModtime <- Dir.getModificationTime "cbits/tracy"
          exeModtime    <- Dir.getModificationTime buildExe
          return (sourceModtime > exeModtime)
      when sourceNewer $ do
        setupMessage $ "Building Tracy executable from C++ source: " ++ exeName
        info $ "Source directory: " ++ sourceDir
        info $ "Build directory: " ++ buildDir
        rawSystemExit verbosity "cmake" $
          "-B" : buildDir : "-S" : sourceDir : cmakeGenerateOpts
        rawSystemExit verbosity "cmake" $
          "--build" : buildDir : cmakeBuildOpts
  where
    sourceDir, buildDir, buildExe :: FilePath
    sourceDir = "cbits/tracy" </> exeSourceDir
    buildDir  = getBuildDir localBuildInfo
    buildExe  = buildDir </> exeFile exeName localBuildInfo

    setupMessage, info :: String -> IO ()
    setupMessage msg =
      Utils.setupMessage verbosity msg (PkgDesc.package pkgDesc)
    info = Utils.infoNoWrap verbosity

-- | Post-copy hook
--
-- When building as a dependency, this hook copies the Tracy executable to the
-- staging directory, so that it is installed in the Cabal Store.
postCopyHook
  :: Simple.Args
  -> Setup.CopyFlags
  -> PackageDescription
  -> LocalBuildInfo
  -> IO ()
postCopyHook args copyFlags pkgDesc localBuildInfo = do
  Simple.postCopy Simple.simpleUserHooks args copyFlags pkgDesc localBuildInfo
  installTracyExe verbosity pkgDesc localBuildInfo copyDest
  where
    verbosity :: Verbosity
    verbosity
      = Setup.fromFlagOrDefault Verbosity.normal
      $ Setup.copyVerbosity copyFlags

    copyDest :: CopyDest
    copyDest
      = Setup.fromFlagOrDefault InstallDirs.NoCopyDest
      $ Setup.copyDest copyFlags

-- | Post-install hook
--
-- When running the @install@ command, this hooks copies the Tracy executable to
-- the staging directory, so that it is installed in the Cabal Store.
postInstHook
  :: Simple.Args
  -> Setup.InstallFlags
  -> PackageDescription
  -> LocalBuildInfo
  -> IO ()
postInstHook args instFlags pkgDesc localBuildInfo = do
  Simple.postInst Simple.simpleUserHooks args instFlags pkgDesc localBuildInfo
  installTracyExe verbosity pkgDesc localBuildInfo InstallDirs.NoCopyDest
  where
    verbosity :: Verbosity
    verbosity
      = Setup.fromFlagOrDefault Verbosity.normal
      $ Setup.installVerbosity instFlags

installTracyExe
  :: Verbosity
  -> PackageDescription
  -> LocalBuildInfo
  -> CopyDest
  -> IO ()
installTracyExe verbosity pkgDesc localBuildInfo copyDest = do
  built <- Dir.doesFileExist buildExe
  when built $ do
    setupMessage $ "Installing Tracy executable: " ++ exe
    info $ "Build directory: " ++ buildDir
    info $ "Install directory: " ++ installDir
    Utils.createDirectoryIfMissingVerbose verbosity True installDir
    Utils.installExecutableFile verbosity buildExe installExe
  where
    exe, buildDir, installDir, buildExe, installExe :: FilePath
    exe        = exeFile exeName localBuildInfo
    buildDir   = getBuildDir localBuildInfo
    installDir = InstallDirs.libexecdir installDirs
    buildExe   = buildDir   </> exe
    installExe = installDir </> exe

    installDirs :: InstallDirs FilePath
    installDirs =
      LocalBuildInfo.absoluteInstallDirs pkgDesc localBuildInfo copyDest

    setupMessage, info :: String -> IO ()
    setupMessage msg =
      Utils.setupMessage verbosity msg (PkgDesc.package pkgDesc)
    info = Utils.infoNoWrap verbosity

{-------------------------------------------------------------------------------
  Auxiliary
-------------------------------------------------------------------------------}

exeFile :: String -> LocalBuildInfo -> FilePath
exeFile exe localBuildInfo =
  exe <.> BuildPaths.exeExtension (LocalBuildInfo.hostPlatform localBuildInfo)

getModulesDir :: LocalBuildInfo -> FilePath
#if MIN_VERSION_Cabal(3,14,0)
getModulesDir localBuildInfo =
  LocalBuildInfo.interpretSymbolicPathLBI
    localBuildInfo
    (BuildPaths.autogenPackageModulesDir localBuildInfo)
#else
getModulesDir = BuildPaths.autogenPackageModulesDir
#endif

getBuildDir :: LocalBuildInfo -> FilePath
getBuildDir localBuildInfo =
#if MIN_VERSION_Cabal(3,14,0)
  LocalBuildInfo.interpretSymbolicPathLBI
    localBuildInfo
    (LocalBuildInfo.buildDir localBuildInfo)
#else
  LocalBuildInfo.buildDir localBuildInfo
#endif
  </> "foreign-tracy"

rawSystemExit :: Verbosity -> FilePath -> [String] -> IO ()
#if MIN_VERSION_Cabal(3,14,0)
rawSystemExit verbosity = Utils.rawSystemExit verbosity Nothing
#else
rawSystemExit = Utils.rawSystemExit
#endif
