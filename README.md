<div align="center">
<img width="450" src="https://github.com/AccelerateHS/accelerate/raw/master/images/accelerate-logo-text-v.png?raw=true" alt="henlo, my name is Theia"/>

# Tracy profiling support for the Accelerate language

[![GitHub CI](https://github.com/AccelerateHS/accelerate-tracy/workflows/CI/badge.svg)](https://github.com/AccelerateHS/accelerate-tracy/actions)

</div>

This package implements support for using the [Tracy profiler][] to profile
[Accelerate][] kernels.

[Tracy profiler]: https://github.com/wolfpld/tracy#tracy-profiler
[Accelerate]: https://www.acceleratehs.org/

## Usage

Tracy profiling support is disabled by default.  Use Cabal flags to enable Tracy
profiling in Accelerate kernels as well as build Tracy executables:

* `+tracy-client` enables Tracy profiling support in Accelerate kernels
* `+tracy-capture` builds the `tracy-capture` executable (CLI)
* `+tracy-profiler` builds the `tracy-profiler` executable (GUI)
* `+tracy` is equivalent to setting all of the above flags

> [!NOTE]
> The API provided by this package is for internal use in Accelerate packages.
> Accelerate users do not need to use this API; simply enable Tracy profiling
> when building your program and use one of the Tracy executables to profile the
> program when running it.

### Client

When Tracy profiling support is enabled (using `+tracy-client` or `+tracy`),
Tracy client code is compiled into Accelerate programs.  The C++ compiler may
display warnings, which GHC displays as (non-fatal) errors.  These are upstream
warnings and may be ignored in the context of this package.

Tracy profiling currently only works with `accelerate-llvm-native`.  For PTX
profiling, use NVIDIA Nsight instead.

### Tracy Executables

> [!IMPORTANT]
> Tracy executables must be the same version of Tracy that the Accelerate
> program was build with.

The following software is required to build the executables:

* `CMake`
* `pkg-config`
* `freetype2`
* `glfw3`
* `gtk3` (Linux only)
* `TBB` (should be part of your compiler toolchain

You can install all of these on Debian/Ubuntu via:

```
sudo apt install cmake pkg-config libfreetype-dev libglfw3-dev libgtk-3-dev libtbb-dev
```

You can install all of these on macOS via:

```
brew install cmake pkg-config freetype glfw
```

## Development

Since this package is for internal use in Accelerate packages, we aim to
minimize the Haskell bindings, only implementing those that are required.

### Cabal

You may specify flags and the GHC version via options, as usual.  Example:

```
cabal build all --with-compiler ghc-9.4.8 -f+tracy
```

If you would like to make some options persist, so that you do not have to
specify them every time, use `cabal configure` to configure options in a
`cabal.project.local` file.  Example:

```
cabal configure --with-compiler ghc-9.4.8 -f+tracy
```

Alternatively, if you would like to maintain `cabal.project.local` yourself and
easily switch between various options, `cabal.project.local.template` provides a
template.

### Stack

Multiple Stack configuration files are provided for each tested version of GHC,
and `stack.yaml` links to the configuration with latest configured LTS.  To test
using a different version, use the `--stack-yaml` option.  Example:

```
stack build --stack-yaml stack-9.4.8.yaml --flag accelerate-tracy:tracy
```

You may temporarily configure flags in Stack configuration, but be careful to
not commit such temporary changes.

If you are on an installation of Windows that does not support symbolic links,
the committed `stack.yaml` does not work.  Use the `--stack-yaml` option to
specify a different configuration file.  Alternatively, copy a versioned
configuration file, replacing `stack.yaml`, but be careful to not commit it.

### HIE/HLS

If you would like to use HIE/HLS with Cabal, create a symbolic link to
`hie.cabal.yaml` named `hie.yaml`.

```
ln -s hie.cabal.yaml hie.yaml
```

Alternatively, if you would like to use HIE/HLS with Stack, create a symbolic
link to `hie.stack.yaml` named `hie.yaml`.

```
ln -s hie.stack.yaml hie.yaml
```

If you are on an installation of Windows that does not support symbolic links,
copying the file works just as well.
