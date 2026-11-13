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

The easiest way to use `tracy-profiler` with Stack is to clone this repository
and configure `accelerate-tracy-profiler-stack` as a *project package*.

For example, a project that clones this repository in the project directory
using a Git submodule could be configured as follows:


```yaml
snapshot: lts-...

packages:
  - .
  - accelerate-tracy/accelerate-tracy-profiler-stack

extra-deps:
  ...

flags:
  accelerate-tracy-lib:
    tracy: true
```

The version of `accelerate-tracy-lib` and `accelerate-tracy-profiler` must be
set by the snapshot or in `extra-deps`, and dependency constraints ensure that
the versions match.  Package `accelerate-tracy-profiler-stack` automatically
uses that version, with no need to checkout any particular commit.

Run the program as follows:

```
stack run tracy-profiler
```

## Development

For information about development, see the repository [README][].

[README]: <https://github.com/AccelerateHS/accelerate-tracy#readme>
