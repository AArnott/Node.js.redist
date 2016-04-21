Param(
    [Parameter()]
    [string]$Version='4.4.3'
)

.\Restore.ps1 -Version $Version
.\Pack.ps1 -Version $Version
