#!/usr/bin/env pwsh

<#
.SYNOPSIS
	Downloads build tools and a particular version of Node.js
	and packages it up.
.PARAMETER Version
	The version of Node.js to download and build a package for.
.PARAMETER AttemptNumber
	A positive integer appended to the NuGet package version for republishing.
#>
Param(
	[Parameter()]
	[string]$Version = '24.22.1',

	[Parameter()]
	[ValidateRange(1, [int]::MaxValue)]
	[int]$AttemptNumber
)

$packParameters = @{}
if ($PSBoundParameters.ContainsKey('AttemptNumber')) {
	$packParameters.AttemptNumber = $AttemptNumber
}

& "$PSScriptRoot\Restore.ps1" -Version $Version
& "$PSScriptRoot\Pack.ps1" -Version $Version @packParameters
