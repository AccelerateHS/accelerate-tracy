#ifndef __ACCELERATE_TRACY_H__
#define __ACCELERATE_TRACY_H__

// Macro API is no-ops when Tracy is disabled

#define AccTracyEmitZoneBegin( ctx, srcloc, color_variant )

#define AccTracyEmitZoneEnd( ctx )

#define AccTracyEmitKernelBeginCB( data )

#define AccTracyEmitKernelEndCB( data )

#define AccTracyEmitMemoryAlloc( ptr, size, secure )

#define AccTracyEmitMemoryFree( ptr, secure )

#endif // __ACCELERATE_TRACY_H__
