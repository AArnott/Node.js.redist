<#
.SYNOPSIS
    Downloads build tools and a particular version of Node.js
    for purposes of later building a package.
.PARAMETER Version
    The version of Node.js to download.
#>
Param(
    [Parameter(Mandatory=$true)]
    [string]$Version
)

$DistRootUri = "https://nodejs.org/dist/v$Version"
$LayoutRoot = "$PSScriptRoot\obj\layout\$Version"
$LayoutRootSymbols = "$PSScriptRoot\obj\layoutsymbols\$Version"
$Script:ProgressPreference = 'SilentlyContinue' # DRAMATIC perf improvement: https://stackoverflow.com/a/43477248/46926
if (!(Test-Path $LayoutRoot)) { $null = mkdir $LayoutRoot }

function Expand-ZIPFile($file, $destination) {
    $shell = new-object -com shell.application
    $zip = $shell.NameSpace((Resolve-Path $file).Path)
    foreach ($item in $zip.items()) {
        $shell.Namespace((Resolve-Path $destination).Path).copyhere($item)
    }
}

if (!(Test-Path $PSScriptRoot\obj)) { $null = mkdir $PSScriptRoot\obj }

$unzipTool = "$PSScriptRoot\obj\7z\7za.exe"
if (Test-Path $unzipTool) {
    Write-Verbose "7-zip found"
} else {
    $zipToolArchive = "$PSScriptRoot\obj\7za920.zip"
    if (Test-Path $zipToolArchive) {
        Write-Verbose "Skipped downloading 7-zip"
    } else {
        Write-Verbose "Downloading 7-zip"
        Invoke-WebRequest -Uri http://7-zip.org/a/7za920.zip -OutFile $zipToolArchive
    }

    if (!(Test-Path $PSScriptRoot\obj\7z)) { $null = mkdir $PSScriptRoot\obj\7z }
    Expand-ZIPFile -file $zipToolArchive -destination $PSScriptRoot\obj\7z
}

Function Get-NetworkFile {
Param(
    [uri]$Uri,
    [string]$OutDir
)
    if (!(Test-Path $OutDir)) {
        $null = mkdir $OutDir
    }

    $OutFile = Join-Path $OutDir $Uri.Segments[$Uri.Segments.Length - 1]
    if (Test-Path $OutFile) {
        Write-Verbose "Skipped download from $Uri"
    } else {
        Write-Verbose "Downloading $Uri"
        try {
            (New-Object System.Net.WebClient).DownloadFile($Uri, $OutFile)
        } finally {
            # This try/finally causes the script to abort
        }
    }

    $OutFile
}

Function Get-NixNode($os, $arch, $osBrand) {
    $tgzPath = "$PSScriptRoot\obj\node-v$Version-$os-$arch.tar.gz"
    $expandedPath = "$PSScriptRoot\obj\node-v$Version-$os-$arch"

    if (!(Test-Path $tgzPath)){
      Get-NetworkFile -Uri $DistRootUri/node-v$Version-$os-$arch.tar.gz -OutDir "$PSScriptRoot\obj"
    }

    if (!(Test-Path $expandedPath)) {
      $tarName = [IO.Path]::GetFileNameWithoutExtension($tgzPath)
      $tarPath = Join-Path $PSScriptRoot\obj $tarName
      $null = & $unzipTool -y -o"$PSScriptRoot\obj" e $tgzPath $tarName
      $null = & $unzipTool -y -o"$expandedPath" x $tarPath
    }

    if (!$osBrand) { $osBrand = $os }
    $targetDir = "$LayoutRoot\tools\$osBrand-$arch"
    if (!(Test-Path $targetDir)) {
        $null = mkdir $targetDir
        $null = mkdir $targetDir\bin
        $null = mkdir $targetDir\lib
    }

    $binDir = "$expandedPath\node-v$Version-$os-$arch\bin\*"
    $libDir = "$expandedPath\node-v$Version-$os-$arch\lib\*"

    Copy-Item -Path $binDir -Destination $targetDir\bin -Recurse -Force
    Copy-Item -Path $libDir -Destination $targetDir\lib -Recurse -Force
}

Function Get-WinNode($arch) {
    $zipPath = "$PSScriptRoot\obj\node-v$Version-win-$arch.zip"
    $expandedPath = "$PSScriptRoot\obj\node-v$Version-win-$arch"

    if (!(Test-Path $zipPath)) {
      Get-NetworkFile -Uri $DistRootUri/node-v$Version-win-$arch.zip -OutDir "$PSScriptRoot\obj"
    }

    if (!(Test-Path $expandedPath)) {
      $null = & $unzipTool -y -o"$expandedPath" x $zipPath
    }

    $targetDir = "$LayoutRoot\tools\win-$arch"
    if (!(Test-Path $targetDir)) {
        $null = mkdir $targetDir
    }

    $binDir = "$expandedPath\node-v$Version-win-$arch\*"

    Copy-Item -Path $binDir -Destination $targetDir -Recurse -Force
}

Function Get-LicenseFile {
    Get-NetworkFile -Uri "https://raw.githubusercontent.com/nodejs/node/v$Version/LICENSE" -OutDir "$PSScriptRoot\obj\$Version"
}

Get-NixNode 'linux' x64
#Get-NixNode 'linux' x86 # Node 10.0.0 removes support for x86 linux
Get-NixNode 'darwin' x64 -osBrand 'osx'
try {
    Get-NixNode 'darwin' arm64 -osBrand 'osx'
} catch {
    Write-Warning "No darwin-arm64 build available for Node.js $Version"
}
Get-WinNode x86
Get-WinNode x64
Get-LicenseFile
