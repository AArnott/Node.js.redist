#!/usr/bin/env pwsh

<#
.SYNOPSIS
	Packages up a particular version of Node.js
	that has previously been restored.
.PARAMETER Version
	The version of Node.js to build a package for.
#>
Param(
	[Parameter(Mandatory = $true)]
	[string]$Version
)

$ErrorActionPreference = "Stop"

$LayoutRoot = "$PSScriptRoot\obj\layout\$Version"
$LayoutRootSymbols = "$PSScriptRoot\obj\layoutsymbols\$Version"

$targetDir = "$PSScriptRoot\bin"
if (!(Test-Path $targetDir)) { $null = mkdir $targetDir }

$Properties = "src=$PSScriptRoot\src;common=$PSScriptRoot\obj\$Version"

$nugetTool = & "$PSScriptRoot\Get-NuGetTool.ps1"

'win','linux','osx' |% {
	Write-Host "Packing binary packages for $_"
	& $nugetTool pack $PSScriptRoot\src\Node.js.redist.$_.nuspec  -BasePath $LayoutRoot\$_ -OutputDirectory $targetDir -Version $Version -Properties $Properties
}

Write-Host "Packing symbols for Windows"
'x86','x64' |% {
	& $nugetTool pack $PSScriptRoot\src\Node.js.redist.symbols.win-$_.nuspec -BasePath $LayoutRootSymbols\win -OutputDirectory $targetDir -Version $Version -Properties $Properties
}
& $nugetTool pack $PSScriptRoot\src\Node.js.redist.symbols.win.nuspec -BasePath $LayoutRootSymbols\win -OutputDirectory $targetDir -Version $Version -Properties $Properties

Write-Host "Packing top-level packages"
& $nugetTool pack $PSScriptRoot\src\Node.js.redist.nuspec         -BasePath $LayoutRoot -OutputDirectory $targetDir -Version $Version -Properties $Properties
& $nugetTool pack $PSScriptRoot\src\Node.js.redist.symbols.nuspec -BasePath $LayoutRootSymbols -OutputDirectory $targetDir -Version $Version -Properties $Properties
