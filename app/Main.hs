-- |
-- Module      : Main
-- Copyright   : [2016..2020] The Accelerate Team
-- License     : BSD3
--
-- Maintainer  : Trevor L. McDonell <trevor.mcdonell@gmail.com>
-- Stability   : experimental
-- Portability : non-portable (GHC extensions)
--
-- This module defines a placeholder executable that is built by Cabal.  A
-- @postBuildHook@ then builds the actual executable using CMake, which should
-- replace the placeholder executable.
module Main (main) where

import qualified System.Environment as Env
import qualified System.Exit as Exit
import qualified System.IO as IO

main :: IO ()
main = do
  progName <- Env.getProgName
  IO.hPutStrLn IO.stderr $ "error: executable not built: " ++ progName
  Exit.exitWith (Exit.ExitFailure 127)
