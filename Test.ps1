#!/usr/bin/env pwsh

<#
.SYNOPSIS
	Tests the packages built by Pack.ps1 to ensure dependencies are all satisfied.
.PARAMETER Version
	The version of Node.js for which packages were built that should be tested.
.PARAMETER AttemptNumber
	The positive integer appended to the NuGet package version when building.
#>
Param(
	[Parameter(Mandatory = $true)]
	[string]$Version,

	[Parameter()]
	[ValidateRange(1, [int]::MaxValue)]
	[int]$AttemptNumber
)

$PackageVersion = $Version
if ($PSBoundParameters.ContainsKey('AttemptNumber')) {
	$PackageVersion = "$Version.$AttemptNumber"
}

$TestOutputDir = Join-Path $PSScriptRoot obj tests
$PackageSource = Join-Path $PSScriptRoot bin
$nugetTool = & "$PSScriptRoot\Get-NuGetTool.ps1"

# Make sure we start with a clean slate
if (Test-Path $TestOutputDir) { Remove-Item -Path $TestOutputDir -Recurse -Force }
New-Item -ItemType Directory -Path $TestOutputDir | Out-Null

'Node.js.redist','Node.js.redist.symbols' |% {
	& $nugetTool install $_ -OutputDirectory $TestOutputDir -Version $PackageVersion -Source $PackageSource
}

# Verify that the expected number of packages were brought down.
$majorVersion = [int]($Version -split '\.')[0]
$expectedCount = (Get-ChildItem $PSScriptRoot\src\*.nuspec).Length
if ($majorVersion -ge 23) {
	$expectedCount-- # Node.js 23+ has no win-x86 artifacts; symbols.win-x86 is not published
}
$actualCount = (Get-ChildItem $TestOutputDir\*).Length

if ($expectedCount -ne $actualCount) {
	Write-Error "Expected: $expectedCount. Actual: $actualCount"
	exit 1
}

Write-Host "PASS"
