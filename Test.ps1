#!/usr/bin/env pwsh

<#
.SYNOPSIS
	Tests the packages built by Pack.ps1 to ensure dependencies are all satisfied.
.PARAMETER Version
	The version of Node.js for which packages were built that should be tested.
#>
Param(
	[Parameter(Mandatory = $true)]
	[string]$Version
)

$TestOutputDir = Join-Path $PSScriptRoot obj tests
$PackageSource = Join-Path $PSScriptRoot bin
$nugetTool = & "$PSScriptRoot\Get-NuGetTool.ps1"

# Make sure we start with a clean slate
if (Test-Path $TestOutputDir) { Remove-Item -Path $TestOutputDir -Recurse -Force }
New-Item -ItemType Directory -Path $TestOutputDir | Out-Null

'Node.js.redist','Node.js.redist.symbols' |% {
	& $nugetTool install $_ -OutputDirectory $TestOutputDir -Version $Version -Source $PackageSource
}

# Verify that the expected number of packages were brought down.
$expectedCount = (Get-ChildItem $PSScriptRoot\src\*.nuspec).Length
$actualCount = (Get-ChildItem $TestOutputDir\*).Length

if ($expectedCount -ne $actualCount) {
	Write-Error "Expected: $expectedCount. Actual: $actualCount"
	exit 1
}

Write-Host "PASS"
