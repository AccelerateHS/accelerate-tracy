<div align="center">
<img width="450" src="https://github.com/AccelerateHS/accelerate/raw/master/images/accelerate-logo-text-v.png?raw=true" alt="henlo, my name is Theia"/>

# Tracy profiling support for the Accelerate language

[![GitHub CI](https://github.com/AccelerateHS/accelerate-tracy/workflows/CI/badge.svg)](https://github.com/AccelerateHS/accelerate-tracy/actions)

</div>

This repository contains the following packages:

* [`accelerate-tracy-lib`](accelerate-tracy-lib/README.md) implements support
  for using [Tracy profiler][] to profile [Accelerate][] kernels.  This package
  is used internally by Accelerate packages.  Accelerate users do not need to
  use this package, aside from setting the `tracy` flag to enable Tracy
  profiling.

* [`accelerate-tracy-capture`](accelerate-tracy-capture/README.md) provides an
  easy way to install the matching version of the `tracy-capture` CLI program.
  Cabal users should use this package directly.
* [`accelerate-tracy-capture-stack`](accelerate-tracy-capture-stack/README.md)
  provides an easy way for Stack users to install the matching version of the
  `tracy-capture` CLI program.

* [`accelerate-tracy-profiler`](accelerate-tracy-profiler/README.md) provides an
  easy way to install the matching version of the `tracy-profiler` GUI program.
  Cabal users should use this package directly.
* [`accelerate-tracy-profiler-stack`](accelerate-tracy-profiler-stack/README.md)
  provides an easy way for Stack users to install the matching version of the
  `tracy-profiler` GUI program.

[Tracy profiler]: <https://github.com/wolfpld/tracy#tracy-profiler>
[Accelerate]: <https://www.acceleratehs.org/>

## Usage

See each package for usage information.

> [!IMPORTANT]
> Tracy executables must be the same version of Tracy that the Accelerate
> program was build with.

## Development

Since this package is for internal use in Accelerate packages, we aim to
minimize the Haskell bindings, only implementing those that are required.

### Git submodules

This repository pins a specific Tracy commit in multiple submodules.  These must
be kept in sync.  This is necessary because of the way that Cabal builds source
distributions.

When you create a new clone or worktree, initialize the submodules as follows:

```
git update --init --recursive
```

You can check the status of the submodules as follows:

```
git submodule status
```

### Versioning

The versions of the following packages must be kept in sync.  Executables depend
on the specific version of the `accelerate-tracy-lib` package, to ensure that
matching versions are installed.

* `accelerate-tracy-lib`
* `accelerate-tracy-capture`
* `accelerate-tracy-profiler`

The Stack helper packages should never/rarely need to change.  They should
support any version of the corresponding executable packages, so that users do
not have to checkout a particular commit.

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
stack build --stack-yaml stack-9.4.8.yaml --flag accelerate-tracy-lib:tracy
```

You may temporarily configure flags in Stack configuration, but be careful to
not commit such temporary changes.

If you are on an installation of Windows that does not support symbolic links,
the committed `stack.yaml` does not work.  Use the `--stack-yaml` option to
specify a different configuration file.  Alternatively, copy a versioned
configuration file, replacing `stack.yaml`, but be careful to not commit it.

Note that `stack run` has problems in this project because the Stack helper
packages have executables with the same name as the Tracy executable packages.
Test these from the context of a different project.

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
