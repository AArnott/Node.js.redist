<#
.SYNOPSIS
    Downloads build tools and a particular version of Node.js
    and packages it up.
.PARAMETER Version
    The version of Node.js to download and build a package for.
#>
Param(
    [Parameter()]
    [string]$Version='4.4.3'
)

& "$PSScriptRoot\Restore.ps1" -Version $Version
& "$PSScriptRoot\Pack.ps1" -Version $Version
