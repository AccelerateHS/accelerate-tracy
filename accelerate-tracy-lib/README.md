<div align="center">
<img width="450" src="https://github.com/AccelerateHS/accelerate/raw/master/images/accelerate-logo-text-v.png?raw=true" alt="henlo, my name is Theia"/>

# `accelerate-tracy-lib`

</div>

This package implements support for using [Tracy profiler][] to profile
[Accelerate][] kernels.

[Tracy profiler]: <https://github.com/wolfpld/tracy#tracy-profiler>
[Accelerate]: <https://www.acceleratehs.org/>

> [!NOTE]
> The API provided by this package is for internal use in Accelerate packages.
> Accelerate users do not need to use this API; simply enable Tracy profiling
> when building your program and use one of the Tracy executables to profile the
> program when running it.

## Usage

Tracy profiling support is disabled by default.  Use Cabal flag `tracy` to
enable profiling.

Tracy profiling currently only works with `accelerate-llvm-native`.  For PTX
profiling, use NVIDIA Nsight instead.

The C++ compiler may display warnings, which GHC displays as (non-fatal) errors.
These are upstream warnings and may be ignored in the context of this package.

### Cabal

Configure the following in your `cabal.project.local`:

```
package accelerate-tracy-lib
  flags: +tracy
```

### Stack

Configure the following in your `stack.yaml`:

```
flags:
  accelerate-tracy-lib:
    tracy: true
```

## Development

For information about development, see the repository [README][].

[README]: <https://github.com/AccelerateHS/accelerate-tracy#readme>
