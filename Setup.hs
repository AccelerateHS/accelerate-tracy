{-# LANGUAGE CPP        #-}
{-# LANGUAGE LambdaCase #-}
{-# OPTIONS -Wall -Wcompat #-}
module Main (main) where

import Control.Monad (forM_, when)
import Data.Maybe (fromMaybe)
import Distribution.PackageDescription (PackageDescription)
import Distribution.PackageDescription qualified as PkgDesc
import Distribution.Simple (Args)
import Distribution.Simple qualified as Simple
import Distribution.Simple.LocalBuildInfo (LocalBuildInfo)
import Distribution.Simple.LocalBuildInfo qualified as LocalBuildInfo
import Distribution.Simple.Setup (BuildFlags)
import Distribution.Simple.Setup qualified as Setup
import Distribution.Simple.Utils qualified as Utils
import Distribution.System (OS, Platform(Platform))
import Distribution.System qualified as System
import Distribution.Verbosity (Verbosity)
import Distribution.Verbosity qualified as Verbosity
import System.Directory qualified as Dir
import System.FilePath ((</>))

#if MIN_VERSION_Cabal(3,14,0)
-- Any changes to path logic must be tested across the range of supported Cabal
-- versions.
import Distribution.Utils.Path qualified as Path
#endif

{-------------------------------------------------------------------------------
  Configuration
-------------------------------------------------------------------------------}

-- | Tracy executable name
type ExecutableName = String

-- | Source directory in @cbits/tracy@ repository
type ExecutableSourceDir = String

-- | Configuration for executables that can be built
executables :: [(ExecutableName, ExecutableSourceDir)]
executables =
  [ ("tracy-capture",  "capture")
  , ("tracy-profiler", "profiler")
  ]

-- | CMake options to pass when generating a project buildsystem
cmakeGenerateOpts :: [String]
cmakeGenerateOpts =
  [ "-DCMAKE_BUILD_TYPE=Release"
  , "-DLEGACY=1"  -- Build with X11 instead of Wayland
  ]

-- | CMake options to pass when building a project
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
    { Simple.postBuild = postBuildHook
    }

postBuildHook
  :: Args
  -> BuildFlags
  -> PackageDescription
  -> LocalBuildInfo
  -> IO ()
postBuildHook _args buildFlags pkgDesc localBuildInfo =
  forM_ executables $ \(exeName, exeSourceDir) ->
    when (tracyEnabled || isFlagEnabled exeName localBuildInfo) $
      case os of
        System.Windows ->
          -- TODO build Tracy executables on Windows
          setupMessage $ "Not building Tracy executable on Windows: " ++ exeName
        _ -> build exeName exeSourceDir
  where
    tracyEnabled :: Bool
    tracyEnabled = isFlagEnabled "tracy" localBuildInfo

    os :: OS
    Platform _arch os = LocalBuildInfo.hostPlatform localBuildInfo

    verbosity :: Verbosity
    verbosity
      = Setup.fromFlagOrDefault Verbosity.normal
      $ Setup.buildVerbosity buildFlags

    setupMessage, info :: String -> IO ()
    setupMessage msg =
      Utils.setupMessage verbosity msg (PkgDesc.package pkgDesc)
    info = Utils.infoNoWrap verbosity

    build :: ExecutableName -> ExecutableSourceDir -> IO ()
    build exeName exeSourceDir = do
      let sourceDir = "cbits/tracy" </> exeSourceDir
          buildDir  = getBuildDir buildFlags localBuildInfo </> exeName
          tmpDir    = buildDir </> exeName ++ "-tmp"
          buildExe  = tmpDir </> exeName
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
        info $ "Temporary directory: " ++ tmpDir
        rawSystemExit verbosity "cmake" $
          "-B" : tmpDir : "-S" : sourceDir : cmakeGenerateOpts
        rawSystemExit verbosity "cmake" $
          "--build" : tmpDir : cmakeBuildOpts
        -- Copy, not rename, so that the above existence test can be used to
        -- avoid rebuilding unnecessarily
        Dir.copyFile buildExe (buildDir </> exeName)

{-------------------------------------------------------------------------------
  Auxiliary
-------------------------------------------------------------------------------}

isFlagEnabled :: String -> LocalBuildInfo -> Bool
isFlagEnabled flag
  = fromMaybe False
  . PkgDesc.lookupFlagAssignment (PkgDesc.mkFlagName flag)
  . Setup.configConfigurationsFlags
  . LocalBuildInfo.configFlags

getBuildDir :: BuildFlags -> LocalBuildInfo -> FilePath
#if MIN_VERSION_Cabal(3,14,0)
getBuildDir buildFlags localBuildInfo =
  Path.interpretSymbolicPath
    ( Setup.flagToMaybe
    . Setup.setupWorkingDir
    $ Setup.buildCommonFlags buildFlags
    )
    (LocalBuildInfo.buildDir localBuildInfo)
#else
getBuildDir _buildFlags = LocalBuildInfo.buildDir
#endif

rawSystemExit :: Verbosity -> FilePath -> [String] -> IO ()
#if MIN_VERSION_Cabal(3,14,0)
rawSystemExit verbosity = Utils.rawSystemExit verbosity Nothing
#else
rawSystemExit = Utils.rawSystemExit
#endif
