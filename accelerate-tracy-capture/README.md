<div align="center">
<img width="450" src="https://github.com/AccelerateHS/accelerate/raw/master/images/accelerate-logo-text-v.png?raw=true" alt="henlo, my name is Theia"/>

# `accelerate-tracy-capture`

</div>

This package provides an easy way to install the `tracy-capture` program of
[Tracy profiler][] for profiling [Accelerate][] kernels.  This is a CLI.  For
the GUI, see package `accelerate-tracy-profiler`.

[Tracy profiler]: <https://github.com/wolfpld/tracy#tracy-profiler>
[Accelerate]: <https://www.acceleratehs.org/>

## Usage

See package `accelerate-tracy-lib` for information about how to enable Tracy
profiling in your Accelerate kernels.  The `tracy-capture` version must exactly
match the version of Tracy used to build when building Accelerate kernels, and
this package ensures that you get the correct version.

### Requirements

The following software is required to build `tracy-capture`:

* `CMake`
* `pkg-config`

You can install all of these on Debian/Ubuntu via:

```
sudo apt install cmake pkg-config
```

You can install all of these on macOS via:

```
brew install cmake pkg-config
```

> [!NOTE]
> This package does not support building `tracy-capture` on Windows yet.

### Cabal

Configure the following in your `cabal.project.local`:

```
extra-packages:
  accelerate-tracy-capture
```

The version is determined automatically by the Cabal solver based on the
Accelerate dependencies in your package.

Run the program as follows:

```
cabal run tracy-capture -- [OPTIONS]
```

### Stack

Configure the following in your `stack.yaml`:

```
extra-deps:
  - accelerate-tracy-capture-0.1.0.0
```

You must specify the same version number as `accelerate-tracy-lib`, either in
your configured snapshot or explicitly specified in `extra-deps`.

## Development

For information about development, see the repository [README][].

[README]: <https://github.com/AccelerateHS/accelerate-tracy#readme>
