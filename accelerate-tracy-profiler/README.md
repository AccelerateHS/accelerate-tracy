<div align="center">
<img width="450" src="https://github.com/AccelerateHS/accelerate/raw/master/images/accelerate-logo-text-v.png?raw=true" alt="henlo, my name is Theia"/>

# `accelerate-tracy-profiler`

</div>

This package provides an easy way to install the `tracy-profiler` program of
[Tracy profiler][] for profiling [Accelerate][] kernels.  This is a GUI.  For
the CLI, see package `accelerate-tracy-capture`.

[Tracy profiler]: <https://github.com/wolfpld/tracy#tracy-profiler>
[Accelerate]: <https://www.acceleratehs.org/>

## Usage

See package `accelerate-tracy-lib` for information about how to enable Tracy
profiling in your Accelerate kernels.  The `tracy-profiler` version must exactly
match the version of Tracy used to build when building Accelerate kernels, and
this package ensures that you get the correct version.

### Requirements

The following software is required to build `tracy-profiler`:

* `CMake`
* `pkg-config`
* `freetype2`
* `glfw3`
* `gtk3` (Linux only)
* `TBB` (should be part of your compiler toolchain)

You can install all of these on Debian/Ubuntu via:

```
sudo apt install cmake pkg-config libfreetype-dev libglfw3-dev libgtk-3-dev libtbb-dev
```

You can install all of these on macOS via:

```
brew install cmake pkg-config freetype glfw
```

> [!NOTE]
> This package does not support building `tracy-profiler` on Windows yet.

### Cabal

Configure the following in your `cabal.project.local`:

```
extra-packages:
  accelerate-tracy-profiler
```

The version is determined automatically by the Cabal solver based on the
Accelerate dependencies in your package.

Run the program as follows:

```
cabal run tracy-profiler
```

### Stack

Configure the following in your `stack.yaml`:

```
extra-deps:
  - accelerate-tracy-profiler-0.1.0.0
```

You must specify the same version number as `accelerate-tracy-lib`, either in
your configured snapshot or explicitly specified in `extra-deps`.

## Development

For information about development, see the repository [README][].

[README]: <https://github.com/AccelerateHS/accelerate-tracy#readme>
