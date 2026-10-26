# Contributing to this repo

## Prerequisites

The scripts in this repo assume a Windows machine.

## Build

Build by running the Build.ps1 script and specifying the version to package.
Build.ps1 defaults to Node.js 24.22.1 LTS. To build and test this release:

```powershell
.\Build.ps1
.\Test.ps1 -Version 24.22.1
```

Specify `-Version` to package a different release. Packages are written to `bin`.
Node.js 23 and later include Windows x64 and ARM64, but not x86.

To publish, run the Build workflow manually with the desired version and enable
`publish`. Pull requests and pushes build and test packages without publishing.

## Publishing

Run the [Build workflow](.github/workflows/build.yml) manually with the Node.js
version to package and `publish` enabled. After the build and package tests pass,
a separate job uses the `Publishing` GitHub environment to sign every NuGet
package with Azure Key Vault, verify the signatures, and push to nuget.org using
trusted publishing. Signing does not recurse into the packages: the upstream
Node.js executables and their signatures are left unchanged. The signing command
explicitly passes `--recurse-containers false` because the signing tool defaults
to signing container contents even when the option is omitted.

The `Packages` workflow artifact contains the unsigned build output. The
`Signed Packages` artifact contains the verified packages used for publishing.
Normal builds and pull requests do not access signing credentials.

### Publishing environment setup

Configure these secrets in the repository's `Publishing` environment:

* `AZURE_CLIENT_ID`
* `AZURE_TENANT_ID`
* `AZURE_SUBSCRIPTION_ID`
* `NUGET_USER` (the nuget.org account used for trusted publishing)

Configure these environment variables:

* `AZURE_KEY_VAULT_URL`
* `AZURE_KEY_VAULT_CERTIFICATE`

Enable immutable GitHub Actions OIDC subjects for the repository and configure
the Azure application's federated credential for the `Publishing` environment,
with issuer `https://token.actions.githubusercontent.com` and audience
`api://AzureADTokenExchange`. The application must have permission to read the
certificate and sign with its key in the vault.

On nuget.org, configure the trusted publishing policy for this repository,
workflow `build.yml`, and environment `Publishing`. Register the signing
certificate with the package owner's nuget.org account if it is not already
registered. Configure environment deployment protections as appropriate for
release approvals and allowed branches.
