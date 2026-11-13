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

package accelerate-tracy-lib
  flags: +tracy
```

The version is determined automatically by the Cabal solver based on the
Accelerate dependencies in your package.

Run the program as follows:

```
cabal run tracy-capture -- [OPTIONS]
```

### Stack

The easiest way to use `tracy-capture` with Stack is to clone this repository
and configure `accelerate-tracy-capture-stack` as a *project package*.

For example, a project that clones this repository in the project directory
using a Git submodule could be configured as follows:


```yaml
snapshot: lts-...

packages:
  - .
  - accelerate-tracy/accelerate-tracy-capture-stack

extra-deps:
  ...

flags:
  accelerate-tracy-lib:
    tracy: true
```

The version of `accelerate-tracy-lib` and `accelerate-tracy-capture` must be set
by the snapshot or in `extra-deps`, and dependency constraints ensure that the
versions match.  Package `accelerate-tracy-capture-stack` automatically uses
that version, with no need to checkout any particular commit.

Run the program as follows:

```
stack run tracy-capture -- [OPTIONS]
```

## Development

For information about development, see the repository [README][].

[README]: <https://github.com/AccelerateHS/accelerate-tracy#readme>
