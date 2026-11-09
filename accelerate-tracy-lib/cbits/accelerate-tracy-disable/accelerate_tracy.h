#ifndef __ACCELERATE_TRACY_H__
#define __ACCELERATE_TRACY_H__

// Actual Tracy API, must match declaration in TracyC.h

struct ___tracy_source_location_data
{
    const char* name;
    const char* function;
    const char* file;
    uint32_t line;
    uint32_t color;
};

// Macro API is no-ops when Tracy is disabled

#define AccTracyEmitZoneBegin( ctx, srcloc, color_variant )

#define AccTracyEmitZoneEnd( ctx )

#define AccTracyEmitMemoryAlloc( ptr, size )

#define AccTracyEmitMemoryFree( ptr )

#endif // __ACCELERATE_TRACY_H__
