{-# LANGUAGE CApiFFI #-}
{-# LANGUAGE CPP     #-}
-- |
-- Module      : Data.Array.Accelerate.FFI.Tracy
-- Copyright   : [2016..2020] The Accelerate Team
-- License     : BSD3
--
-- Maintainer  : Trevor L. McDonell <trevor.mcdonell@gmail.com>
-- Stability   : experimental
-- Portability : non-portable (GHC extensions)
--

module Data.Array.Accelerate.Tracy (

  -- * Meta
  tracyIsEnabled,

  -- * API
  emitMemoryAlloc, emitMemoryFree, emitMemoryAllocNamed, emitMemoryFreeNamed,
  emitFrameMarkStart, emitFrameMarkEnd,

) where

import Data.Int
import Foreign.C.String
import Foreign.C.Types
import Foreign.Ptr

{-------------------------------------------------------------------------------
  Meta
-------------------------------------------------------------------------------}

-- | 'True' when Tracy is enabled
{-# INLINE tracyIsEnabled #-}
tracyIsEnabled :: Bool
#ifdef ACCELERATE_TRACY
tracyIsEnabled = True
#else
tracyIsEnabled = False
#endif

{-------------------------------------------------------------------------------
  API
-------------------------------------------------------------------------------}

-- | @___tracy_emit_memory_alloc@
emitMemoryAlloc
  :: Ptr a  -- ^ @ptr@
  -> CSize  -- ^ @size@
  -> Int32  -- ^ @secure@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitMemoryAlloc = emitMemoryAlloc'
foreign import capi unsafe "tracy/TracyC.h ___tracy_emit_memory_alloc"
  emitMemoryAlloc'
    :: Ptr a
    -> CSize
    -> Int32
    -> IO ()
#else
emitMemoryAlloc = stub
#endif

-- | @___tracy_emit_memory_free@
emitMemoryFree
  :: Ptr a  -- ^ @ptr@
  -> Int32  -- ^ @size@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitMemoryFree = emitMemoryFree'
foreign import capi unsafe "tracy/TracyC.h ___tracy_emit_memory_free"
  emitMemoryFree'
    :: Ptr a
    -> Int32
    -> IO ()
#else
emitMemoryFree = stub
#endif

-- | @___tracy_emit_memory_alloc_named@
emitMemoryAllocNamed
  :: Ptr a    -- ^ @ptr@
  -> CSize    -- ^ @size@
  -> Int32    -- ^ @secure@
  -> CString  -- ^ @name@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitMemoryAllocNamed = emitMemoryAllocNamed'
foreign import capi unsafe "tracy/TracyC.h ___tracy_emit_memory_alloc_named"
  emitMemoryAllocNamed'
    :: Ptr a
    -> CSize
    -> Int32
    -> CString
    -> IO ()
#else
emitMemoryAllocNamed = stub
#endif

-- | @___tracy_emit_memory_free_named@
emitMemoryFreeNamed
  :: Ptr a    -- ^ @ptr@
  -> Int32    -- ^ @secure@
  -> CString  -- ^ @name@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitMemoryFreeNamed = emitMemoryFreeNamed'
foreign import capi unsafe "tracy/TracyC.h ___tracy_emit_memory_free_named"
  emitMemoryFreeNamed'
    :: Ptr a
    -> Int32
    -> CString
    -> IO ()
#else
emitMemoryFreeNamed = stub
#endif

-- | @___tracy_emit_frame_mark_start@
emitFrameMarkStart
  :: CString  -- ^ @name@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitFrameMarkStart = emitFrameMarkStart'
foreign import capi unsafe "tracy/TracyC.h ___tracy_emit_frame_mark_start"
  emitFrameMarkStart'
    :: CString
    -> IO ()
#else
emitFrameMarkStart = stub
#endif

-- | @___tracy_emit_frame_mark_end@
emitFrameMarkEnd
  :: CString  -- ^ @name@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitFrameMarkEnd = emitFrameMarkEnd'
foreign import capi unsafe "tracy/TracyC.h ___tracy_emit_frame_mark_end"
  emitFrameMarkEnd'
    :: CString
    -> IO ()
#else
emitFrameMarkEnd = stub
#endif

{-------------------------------------------------------------------------------
  Auxiliary
-------------------------------------------------------------------------------}

class Stub a where
  stub :: a

instance Stub b => Stub (x -> b) where
  stub = const stub

instance Stub b => Stub (IO b) where
  stub = return stub

instance Stub () where
  stub = ()

instance Stub Int32 where
  stub = 0
