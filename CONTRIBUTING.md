# Contributing to this repo

## Prerequisites

The scripts in this repo assume a Windows machine.

## Build

Build.ps1 defaults to Node.js 24.22.1 LTS. To build and test this release:

```powershell
.\Build.ps1
.\Test.ps1 -Version 24.22.1
```

Specify `-Version` to package a different release. Packages are written to `bin`.
Node.js 23 and later include Windows x64 and ARM64, but not x86.

To publish, run the Build workflow manually with the desired version and enable
`publish`. Pull requests and pushes build and test packages without publishing.
