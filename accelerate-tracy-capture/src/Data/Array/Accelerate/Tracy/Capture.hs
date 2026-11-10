-- |
-- Module      : Data.Array.Accelerate.Tracy.Capture
-- Copyright   : [2008..2026] The Accelerate Team
-- License     : BSD3
--
-- Maintainer  : Trevor L. McDonell <trevor.mcdonell@gmail.com>
-- Stability   : experimental
-- Portability : non-portable (GHC extensions)
module Data.Array.Accelerate.Tracy.Capture (defaultMain) where

import Control.Monad (filterM)
import Data.Maybe (listToMaybe)
import Paths_accelerate_tracy_capture qualified
import PathsBuild_accelerate_tracy_capture qualified
import System.Directory qualified as Dir
import System.Environment qualified as Env
import System.Exit qualified as Exit
import System.FilePath ((<.>), (</>))
import System.IO qualified as IO
import System.Process qualified as Proc

-- | Locate and run Tracy executable @tracy-capture@, passing any command-line
-- arguments
--
-- The Tracy executable is built by @Setup.hs@.  This program first looks for
-- it in the build directory, required when building locally.  The build
-- directory is known via @PathsBuild_accelerate_tracy_capture@, also created
-- by @Setup.hs@.  When not found, this program then looks for it in the
-- @libexec@ directory (in the Cabal store).  When not found in either
-- directory, this program prints an error and exits with exit code 127.
defaultMain :: IO a
defaultMain = do
  libexecDir <- Paths_accelerate_tracy_capture.getLibexecDir
  exePaths <- filterM Dir.doesFileExist
    [ PathsBuild_accelerate_tracy_capture.foreignTracyBuildDir </> exe
    , libexecDir </> exe
    ]
  exitCode <- case listToMaybe exePaths of
    Just exePath -> do
      args <- Env.getArgs
      Proc.withCreateProcess (Proc.proc exePath args) $
        \_stdin _stdout _stderr -> Proc.waitForProcess
    Nothing -> do
      mapM_ (IO.hPutStrLn IO.stderr)
        [ "error: Tracy executable not found: " ++ exe
        , "  foreignTracyBuildDir: " ++
            PathsBuild_accelerate_tracy_capture.foreignTracyBuildDir
        , "  libexecDir: " ++ libexecDir
        ]
      return (Exit.ExitFailure 127)
  Exit.exitWith exitCode
  where
    exe :: FilePath
    exe = "tracy-capture" <.> Dir.exeExtension
