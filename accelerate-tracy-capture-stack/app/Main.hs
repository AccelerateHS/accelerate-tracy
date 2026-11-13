-- |
-- Module      : Main
-- Copyright   : [2008..2026] The Accelerate Team
-- License     : BSD3
--
-- Maintainer  : Trevor L. McDonell <trevor.mcdonell@gmail.com>
-- Stability   : experimental
-- Portability : non-portable (GHC extensions)
module Main (main) where

import qualified Data.Array.Accelerate.Tracy.Capture

main :: IO ()
main = Data.Array.Accelerate.Tracy.Capture.defaultMain
