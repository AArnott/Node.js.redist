# Node.js.redist

This set of packages contains the node.js executable and debugging symbols necessary to run .js scripts on any desktop OS.

The package version is based on the Node.js version that they contain.

## Family of packages

The matrix of OS and architecture requires several binaries to be packed.
These binaries would lead a single NuGet package to exceed the nuget.org compressed size limit of 250MB.
As a result, we have a couple of top-level packages which depend on other packages so that you can get all the binaries you want, whether that is for all OSs or just a subset.

### Top-level packages

These packages bring in binaries applicable to every desktop OS and architecture via package dependencies:

- `Node.js.redist` brings in the node.js executables
- `Node.js.redist.symbols` brings in the debugger symbols for the executables.

### Per-platform packages

The following packages are specific to a particular OS:

Package ID | OS | Payload
--|--|--
`Node.js.redist.win` | Windows | Node.js executable binary
`Node.js.redist.linux` | Linux | Node.js executable binary
`Node.js.redist.osx` | MacOS | Node.js executable binary
`Node.js.redist.symbols.win` | Windows | Dependencies on all `Node.js.redist.symbols.win-*` packages
`Node.js.redist.symbols.win-x86` | Windows x86 | Node.js debugger symbols
`Node.js.redist.symbols.win-x64` | Windows x64 | Node.js debugger symbols
`Node.js.redist.symbols.win-arm64` | Windows arm64 | Node.js debugger symbols
