Param(
    [Parameter(Mandatory=$true)]
    [string]$Version
)

$LayoutRoot = "$PSScriptRoot\obj\layout\$Version"

$targetDir = "$PSScriptRoot\bin"
if (!(Test-Path $targetDir)) { $null = mkdir $targetDir } 

nuget pack $PSScriptRoot\src\Node.js.redist.nuspec -BasePath $LayoutRoot -OutputDirectory $targetDir -Version $Version
