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

  -- * Types
  SrcLoc, Zone,

  -- * API
  startupProfiler, shutdownProfiler,
  tracyConnected,
  allocSrcloc, allocSrclocName,
  emitZoneBegin, emitZoneEnd,
  emitZoneText, emitZoneName, emitZoneColor, emitZoneValue,
  emitMemoryAlloc, emitMemoryFree, emitMemoryAllocNamed, emitMemoryFreeNamed,
  emitMessage, emitMessageColor, emitMessageLiteral, emitMessageLiteralColor,
  emitFrameMark, emitFrameMarkStart, emitFrameMarkEnd, emitFrameImage,
  emitPlot,
  emitMessageAppinfo,
  fiberEnter, fiberLeave,

) where

import Data.Int
import Data.Word
import Foreign.C.String
import Foreign.C.Types
import Foreign.Ptr

{-------------------------------------------------------------------------------
  Types
-------------------------------------------------------------------------------}

-- | Tracy source location data
--
-- This is returned as an @uint64_t@ by function @___tracy_alloc_srcloc@ and
-- @___tracy_alloc_srcloc_name@, /but/ it is cast as a
-- @const struct ___tracy_source_location_data*@ parameters of functions
-- @___tracy_emit_zone_begin@ and @___tracy_emit_zone_begin_callstack@.
type SrcLoc = Word64

-- | Tracy zone context
--
-- This type corresponds to C type @TracyCZoneCtx@, defined as
-- @typedef struct ___tracy_c_zone_context TracyCZoneCtx@, which is passed and
-- returned by value.
--
-- This Haskell API treats the values as 'Word64'.  The layout of a C @struct@
-- depends on the compiler and system, so this works on some systems but is not
-- cross-platform-safe.  We should not do this.  @TracyCZoneCtx@ is changed in
-- later versions of Tracy, so we will need to remove this from the Haskell API
-- or refactor regardless.
--
-- NOTE We cannot use @capi@ when dealing with 'Zone' because 'Zone' is an
-- unsafe hack.
type Zone = Word64

{-------------------------------------------------------------------------------
  API
-------------------------------------------------------------------------------}

-- | @___tracy_startup_profiler@
startupProfiler :: IO ()
#if defined(ACCELERATE_TRACY) && defined(TRACY_MANUAL_LIFETIME)
startupProfiler = startupProfiler'
foreign import capi unsafe "tracy/TracyC.h ___tracy_startup_profiler"
  startupProfiler' :: IO ()
#else
startupProfiler = stub
#endif

-- | @___tracy_shutdown_profiler@
shutdownProfiler :: IO ()
#if defined(ACCELERATE_TRACY) && defined(TRACY_MANUAL_LIFETIME)
shutdownProfiler = shutdownProfiler'
foreign import capi unsafe "tracy/TracyC.h ___tracy_shutdown_profiler"
  shutdownProfiler' :: IO ()
#else
shutdownProfiler = stub
#endif

-- | @___tracy_connected@
tracyConnected :: IO Int32
#if defined(ACCELERATE_TRACY)
tracyConnected = tracyConnected'
foreign import capi unsafe "tracy/TracyC.h ___tracy_connected"
  tracyConnected' :: IO Int32
#else
tracyConnected = stub
#endif

-- | @___tracy_alloc_srcloc@
allocSrcloc
  :: Word32   -- ^ @line@
  -> CString  -- ^ @source@
  -> CSize    -- ^ @sourceSz@
  -> CString  -- ^ @function@
  -> CSize    -- ^ @functionSz@
  -> Word32   -- ^ @color@
  -> IO SrcLoc
#if defined(ACCELERATE_TRACY)
allocSrcloc = allocSrcloc'
foreign import capi unsafe "tracy/TracyC.h ___tracy_alloc_srcloc"
  allocSrcloc'
    :: Word32
    -> CString
    -> CSize
    -> CString
    -> CSize
    -> Word32
    -> IO SrcLoc
#else
allocSrcloc = stub
#endif

-- | @___tracy_alloc_srcloc_name@
allocSrclocName
  :: Word32   -- ^ @line@
  -> CString  -- ^ @source@
  -> CSize    -- ^ @sourceSz@
  -> CString  -- ^ @function@
  -> CSize    -- ^ @functionSz@
  -> CString  -- ^ @name@
  -> CSize    -- ^ @nameSz@
  -> Word32   -- ^ @color@
  -> IO SrcLoc
#if defined(ACCELERATE_TRACY)
allocSrclocName = allocSrclocName'
foreign import capi unsafe "tracy/TracyC.h ___tracy_alloc_srcloc_name"
  allocSrclocName'
    :: Word32
    -> CString
    -> CSize
    -> CString
    -> CSize
    -> CString
    -> CSize
    -> Word32
    -> IO SrcLoc
#else
allocSrclocName = stub
#endif

-- | @___tracy_emit_zone_begin_alloc@
emitZoneBegin
  :: SrcLoc  -- ^ @srcloc@
  -> Int32   -- ^ @active@
  -> IO Zone
#if defined(ACCELERATE_TRACY)
emitZoneBegin = emitZoneBegin'
foreign import ccall unsafe "___tracy_emit_zone_begin_alloc"
  emitZoneBegin'
    :: SrcLoc
    -> Int32
    -> IO Zone
#else
emitZoneBegin = stub
#endif

-- | @___tracy_emit_zone_end@
emitZoneEnd
  :: Zone  -- ^ @ctx@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitZoneEnd = emitZoneEnd'
foreign import ccall unsafe "___tracy_emit_zone_end"
  emitZoneEnd'
    :: Zone
    -> IO ()
#else
emitZoneEnd = stub
#endif

-- | @___tracy_emit_zone_text@
emitZoneText
  :: Zone     -- ^ @ctx@
  -> CString  -- ^ @txt@
  -> CSize    -- ^ @size@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitZoneText = emitZoneText'
foreign import ccall unsafe "___tracy_emit_zone_text"
  emitZoneText'
    :: Zone
    -> CString
    -> CSize
    -> IO ()
#else
emitZoneText = stub
#endif

-- | @___tracy_emit_zone_name@
emitZoneName
  :: Zone     -- ^ @ctx@
  -> CString  -- ^ @txt@
  -> CSize    -- ^ @size@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitZoneName = emitZoneName'
foreign import ccall unsafe "___tracy_emit_zone_name"
  emitZoneName'
    :: Zone
    -> CString
    -> CSize
    -> IO ()
#else
emitZoneName = stub
#endif

-- | @___tracy_emit_zone_color@
emitZoneColor
  :: Zone    -- ^ @ctx@
  -> Word32  -- ^ @color@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitZoneColor = emitZoneColor'
foreign import ccall unsafe "___tracy_emit_zone_color"
  emitZoneColor'
    :: Zone
    -> Word32
    -> IO ()
#else
emitZoneColor = stub
#endif

-- | @___tracy_emit_zone_value@
emitZoneValue
  :: Zone    -- ^ @ctx@
  -> Word64  -- ^ @value@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitZoneValue = emitZoneValue'
foreign import ccall unsafe "___tracy_emit_zone_value"
  emitZoneValue'
    :: Zone
    -> Word64
    -> IO ()
#else
emitZoneValue = stub
#endif

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

-- | @___tracy_emit_message@
emitMessage
  :: CString  -- ^ @txt@
  -> CSize    -- ^ @size@
  -> Int32    -- ^ @callstack_depth@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitMessage = emitMessage'
foreign import capi unsafe "tracy/TracyC.h ___tracy_emit_message"
  emitMessage'
    :: CString
    -> CSize
    -> Int32
    -> IO ()
#else
emitMessage = stub
#endif

-- | @___tracy_emit_messageC@
emitMessageColor
  :: CString  -- ^ @txt@
  -> CSize    -- ^ @size@
  -> Word32   -- ^ @color@
  -> Int32    -- ^ @callstack_depth@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitMessageColor = emitMessageColor'
foreign import capi unsafe "tracy/TracyC.h ___tracy_emit_messageC"
  emitMessageColor'
    :: CString
    -> CSize
    -> Word32
    -> Int32
    -> IO ()
#else
emitMessageColor = stub
#endif

-- | @___tracy_emit_messageL@
emitMessageLiteral
  :: CString  -- ^ @txt@
  -> Int32    -- ^ @callstack_depth@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitMessageLiteral = emitMessageLiteral'
foreign import capi unsafe "tracy/TracyC.h ___tracy_emit_messageL"
  emitMessageLiteral'
    :: CString
    -> Int32
    -> IO ()
#else
emitMessageLiteral = stub
#endif

-- | @___tracy_emit_messageLC@
emitMessageLiteralColor
  :: CString  -- ^ @txt@
  -> Word32   -- ^ @color@
  -> Int32    -- ^ @callstack_depth@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitMessageLiteralColor = emitMessageLiteralColor'
foreign import capi unsafe "tracy/TracyC.h ___tracy_emit_messageLC"
  emitMessageLiteralColor'
    :: CString
    -> Word32
    -> Int32
    -> IO ()
#else
emitMessageLiteralColor = stub
#endif

-- | @___tracy_emit_frame_mark@
emitFrameMark
  :: CString  -- ^ @name@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitFrameMark = emitFrameMark'
foreign import capi unsafe "tracy/TracyC.h ___tracy_emit_frame_mark"
  emitFrameMark'
    :: CString
    -> IO ()
#else
emitFrameMark = stub
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

-- | @___tracy_emit_frame_image@
emitFrameImage
  :: Ptr Word32  -- ^ @image@
  -> Word16      -- ^ @w@ (width, must be divisible by 4)
  -> Word16      -- ^ @h@ (height, must be divisible by 4)
  -> Word8       -- ^ @offset@
  -> Int32       -- ^ @flip@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitFrameImage = emitFrameImage'
foreign import capi unsafe "tracy/TracyC.h ___tracy_emit_frame_image"
  emitFrameImage'
    :: Ptr Word32
    -> Word16
    -> Word16
    -> Word8
    -> Int32
    -> IO ()
#else
emitFrameImage = stub
#endif

-- | @___tracy_emit_plot@
emitPlot
  :: CString  -- ^ @name@
  -> Double   -- ^ @val@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitPlot = emitPlot'
foreign import capi unsafe "tracy/TracyC.h ___tracy_emit_plot"
  emitPlot'
    :: CString
    -> Double
    -> IO ()
#else
emitPlot = stub
#endif

-- | @___tracy_emit_message_appinfo@
emitMessageAppinfo
  :: CString  -- ^ @txt@
  -> CSize    -- ^ @size@
  -> IO ()
#if defined(ACCELERATE_TRACY)
emitMessageAppinfo = emitMessageAppinfo'
foreign import capi unsafe "tracy/TracyC.h ___tracy_emit_message_appinfo"
  emitMessageAppinfo'
    :: CString
    -> CSize
    -> IO ()
#else
emitMessageAppinfo = stub
#endif

-- | @___tracy_fiber_enter@
fiberEnter
  :: CString  -- ^ @fiber@
  -> IO ()
#if defined(ACCELERATE_TRACY) && defined(TRACY_FIBERS)
fiberEnter = fiberEnter'
foreign import capi unsafe "tracy/TracyC.h ___tracy_fiber_enter"
  fiberEnter'
    :: CString
    -> IO ()
#else
fiberEnter = stub
#endif

-- | @___tracy_fiber_leave@
fiberLeave :: IO ()
#if defined(ACCELERATE_TRACY) && defined(TRACY_FIBERS)
fiberLeave = fiberLeave'
foreign import capi unsafe "tracy/TracyC.h ___tracy_fiber_leave"
  fiberLeave' :: IO ()
#else
fiberLeave = stub
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

instance Stub Word64 where
  stub = 0
