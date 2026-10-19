#ifndef __ACCELERATE_TRACY_H__
#define __ACCELERATE_TRACY_H__

#include <stddef.h>
#include <stdint.h>

// Flag set when Tracy is enabled
#define ACCELERATE_TRACY

// Actual Tracy API, must match declaration in TracyC.h

struct ___tracy_source_location_data
{
    const char* name;
    const char* function;
    const char* file;
    uint32_t line;
    uint32_t color;
};

struct ___tracy_c_zone_context
{
    uint32_t id;
    int32_t active;
};

// Unsafe hack, which we can no longer do with recent versions of Tracy
typedef uint64_t TracyCZoneCtx;

extern TracyCZoneCtx ___tracy_emit_zone_begin( const struct ___tracy_source_location_data* srcloc, int32_t active );

extern TracyCZoneCtx ___tracy_emit_zone_begin_alloc( uint64_t srcloc, int32_t active );

extern void ___tracy_emit_zone_end( TracyCZoneCtx ctx );

extern void ___tracy_emit_zone_color( TracyCZoneCtx ctx, uint32_t color );

extern void ___tracy_emit_memory_alloc( const void* ptr, size_t size, int32_t secure );

extern void ___tracy_emit_memory_free( const void* ptr, int32_t secure );

// Accelerate extras

typedef enum {
  COLOR_DARK,
  COLOR_NORMAL,
  COLOR_LIGHT,
} ColorVariant;

static uint32_t acc_min(uint32_t a, uint32_t b) {
  return a < b ? a : b;
}

static uint32_t acc_get_color_variant(uint32_t color, ColorVariant variant) {
  uint32_t r = (color >> 16) & 0xFF;
  uint32_t g = (color >> 8)  & 0xFF;
  uint32_t b = color         & 0xFF;

  switch (variant) {
    case COLOR_DARK:
      r = (r * 2) / 5;
      g = (g * 2) / 5;
      b = (b * 2) / 5;
      break;

    case COLOR_NORMAL:
      break;

    case COLOR_LIGHT:
      r = acc_min((r * 7) / 5, 0xFF);
      g = acc_min((g * 7) / 5, 0xFF);
      b = acc_min((b * 7) / 5, 0xFF);
      break;
  }

  return ((r & 0xFF) << 16) |
         ((g & 0xFF) << 8)  |
         ((b & 0xFF));
}

void acc_tracy_emit_kernel_begin_cb(void *data) {
  uint64_t *payload = (uint64_t*) data;
  payload[1] = ___tracy_emit_zone_begin_alloc(payload[0], 1);
}

void acc_tracy_emit_kernel_end_cb(void *data) {
  uint64_t *payload = (uint64_t*) data;
  ___tracy_emit_zone_end(payload[1]);
  /* free(data); */
}

// Macro API backed by actual functions

#define AccTracyEmitZoneBegin( ctx, srcloc, color_variant ) \
  TracyCZoneCtx ctx = ___tracy_emit_zone_begin(srcloc, 1); \
  ___tracy_emit_zone_color(ctx, acc_get_color_variant((srcloc)->color, color_variant))

#define AccTracyEmitZoneEnd( ctx ) ___tracy_emit_zone_end(ctx)

#define AccTracyEmitKernelBeginCB( data ) acc_tracy_emit_kernel_begin_cb(data)

#define AccTracyEmitKernelEndCB( data ) acc_tracy_emit_kernel_end_cb(data)

#define AccTracyEmitMemoryAlloc( ptr, size, secure ) ___tracy_emit_memory_alloc(ptr, size, secure)

#define AccTracyEmitMemoryFree( ptr, secure ) ___tracy_emit_memory_free(ptr, secure)

#endif // __ACCELERATE_TRACY_H__
