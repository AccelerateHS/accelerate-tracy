<div align="center">
<img width="450" src="https://github.com/AccelerateHS/accelerate/raw/master/images/accelerate-logo-text-v.png?raw=true" alt="henlo, my name is Theia"/>

# `accelerate-tracy-profiler-stack`

</div>

This package provides an easy way to install the `tracy-profiler` program of
[Tracy profiler][] for profiling [Accelerate][] kernels when using Stack.  This
is a GUI.  For the CLI, see package `accelerate-tracy-capture`.

[Tracy profiler]: <https://github.com/wolfpld/tracy#tracy-profiler>
[Accelerate]: <https://www.acceleratehs.org/>

## Usage

See package `accelerate-tracy-lib` for information about how to enable Tracy
profiling in your Accelerate kernels.

> [!NOTE]
> This package is a convenience for Stack users.  It is not on Hackage, as it
> must used locally.
>
> Cabal users should use package `accelerate-tracy-profiler` directly, *not*
> this package.

### Requirements

See package `accelerate-tracy-profiler` for requirements information.

> [!NOTE]
> This package does not support building `tracy-profiler` on Windows yet.

### Stack

Clone this repository and configure `accelerate-tracy-profiler-stack` as a
*project package*.

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
