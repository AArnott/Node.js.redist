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
$majorVersion = [int]($Version -split '\.')[0]
$winArchitectures = if ($majorVersion -ge 23) { 'x64','arm64' } else { 'x86','x64','arm64' }
$winArchitectures |% {
	& $nugetTool pack $PSScriptRoot\src\Node.js.redist.symbols.win-$_.nuspec -BasePath $LayoutRootSymbols\win -OutputDirectory $targetDir -Version $Version -Properties $Properties
}

# Generate a temporary symbols.win.nuspec that only lists the architectures available for this version.
$symbolsWinNuspecPath = "$PSScriptRoot\src\Node.js.redist.symbols.win.nuspec"
if ($winArchitectures -notcontains 'x86') {
	[xml]$symbolsWinNuspec = Get-Content $symbolsWinNuspecPath
	$ns = New-Object System.Xml.XmlNamespaceManager($symbolsWinNuspec.NameTable)
	$ns.AddNamespace('n', 'http://schemas.microsoft.com/packaging/2011/08/nuspec.xsd')
	$x86Dep = $symbolsWinNuspec.SelectSingleNode('//n:dependency[@id="Node.js.redist.symbols.win-x86"]', $ns)
	if ($x86Dep) { $null = $x86Dep.ParentNode.RemoveChild($x86Dep) }
	if (!(Test-Path $PSScriptRoot\obj)) { $null = mkdir $PSScriptRoot\obj }
	$symbolsWinNuspecPath = "$PSScriptRoot\obj\Node.js.redist.symbols.win.nuspec"
	$symbolsWinNuspec.Save($symbolsWinNuspecPath)
}
& $nugetTool pack $symbolsWinNuspecPath -BasePath $LayoutRootSymbols\win -OutputDirectory $targetDir -Version $Version -Properties $Properties

Write-Host "Packing top-level packages"
& $nugetTool pack $PSScriptRoot\src\Node.js.redist.nuspec         -BasePath $LayoutRoot -OutputDirectory $targetDir -Version $Version -Properties $Properties
& $nugetTool pack $PSScriptRoot\src\Node.js.redist.symbols.nuspec -BasePath $LayoutRootSymbols -OutputDirectory $targetDir -Version $Version -Properties $Properties
