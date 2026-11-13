<div align="center">
<img width="450" src="https://github.com/AccelerateHS/accelerate/raw/master/images/accelerate-logo-text-v.png?raw=true" alt="henlo, my name is Theia"/>

# `accelerate-tracy-capture-stack`

</div>

This package provides an easy way to install the `tracy-capture` program of
[Tracy profiler][] for profiling [Accelerate][] kernels when using Stack.  This
is a CLI.  For the GUI, see package `accelerate-tracy-profiler`.

[Tracy profiler]: <https://github.com/wolfpld/tracy#tracy-profiler>
[Accelerate]: <https://www.acceleratehs.org/>

## Usage

See package `accelerate-tracy-lib` for information about how to enable Tracy
profiling in your Accelerate kernels.

> [!NOTE]
> This package is a convenience for Stack users.  It is not on Hackage, as it
> must used locally.
>
> Cabal users should use package `accelerate-tracy-capture` directly, *not* this
> package.

### Requirements

See package `accelerate-tracy-capture` for requirements information.

> [!NOTE]
> This package does not support building `tracy-capture` on Windows yet.

### Stack

Clone this repository and configure `accelerate-tracy-capture-stack` as a
*project package*.

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
