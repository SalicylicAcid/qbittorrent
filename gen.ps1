<#
.SYNOPSIS
    Generates qBittorrent themes from JSON definitions (PowerShell version).
    
.DESCRIPTION
    This script builds Qt client themes (.qbtheme) and WebUI archives (.zip) 
    using the theme definitions in the themes/ directory.
    
    Prerequisites:
    - 'rcc' (Qt Resource Compiler) must be in your PATH to build Qt themes.
    
.EXAMPLE
    .\gen.ps1
    Builds all themes.

.EXAMPLE
    .\gen.ps1 -ThemeFile themes\dracula.json
    Builds only the Dracula theme.

.EXAMPLE
    .\gen.ps1 -NoQt
    Builds only WebUI themes (does not require rcc).
#>

param(
    [string]$ThemeFile,
    [switch]$NoQt,
    [switch]$NoWebUI,
    [switch]$NoPalette
)

$ErrorActionPreference = "Stop"

# Configuration
$BaseDir = $PSScriptRoot
$TemplateDir = Join-Path $BaseDir "template\qt"
$TemplateWebUIDir = Join-Path $BaseDir "template\webui"
$OutputDirQt = Join-Path $BaseDir "qt"
$OutputDirWebUI = Join-Path $BaseDir "webui"
$OutputDirAssets = Join-Path $BaseDir "assets"

# Check dependencies
$RccPath = Get-Command "rcc" -ErrorAction SilentlyContinue
if (-not $RccPath -and -not $NoQt) {
    Write-Warning "rcc (Qt Resource Compiler) not found in PATH."
    Write-Warning "Qt themes (.qbtheme) will NOT be built. Use -NoQt to suppress this warning."
    $NoQt = $true
}

# Ensure output directories exist
if (-not $NoQt) { New-Item -ItemType Directory -Force -Path $OutputDirQt | Out-Null }
if (-not $NoWebUI) { New-Item -ItemType Directory -Force -Path $OutputDirWebUI | Out-Null }
if (-not $NoPalette) { New-Item -ItemType Directory -Force -Path $OutputDirAssets | Out-Null }

function Build-Theme {
    param([string]$JsonPath)

    if (-not (Test-Path $JsonPath)) {
        Write-Error "Theme file not found: $JsonPath"
        return
    }

    $JsonContent = Get-Content $JsonPath -Raw | ConvertFrom-Json
    $ThemeName = [System.IO.Path]::GetFileNameWithoutExtension($JsonPath)
    
    Write-Host "Building theme: $ThemeName" -ForegroundColor Cyan

    # Prepare replacements map
    $Replacements = @{}
    foreach ($prop in $JsonContent.colors.PSObject.Properties) {
        $Replacements[$prop.Name] = $prop.Value
    }

    # Helper to perform replacements
    function Apply-Replacements($Content) {
        $Result = $Content
        foreach ($Key in $Replacements.Keys) {
            $Placeholder = "%$Key%"
            # Use strict string replacement to avoid regex issues with colors like strings
            $Result = $Result.Replace($Placeholder, $Replacements[$Key])
        }
        return $Result
    }

    # 1. Generate Palette SVG
    if (-not $NoPalette) {
        $SvgPath = Join-Path $OutputDirAssets "palette-$ThemeName.svg"
        $SvgContent = @"
<svg width="80" height="40" xmlns="http://www.w3.org/2000/svg">
  <rect x="0" y="0" width="20" height="20" fill="$($Replacements['BG_PRIMARY'])"/>
  <rect x="20" y="0" width="20" height="20" fill="$($Replacements['BG_SECONDARY'])"/>
  <rect x="40" y="0" width="20" height="20" fill="$($Replacements['FG_PRIMARY'])"/>
  <rect x="60" y="0" width="20" height="20" fill="$($Replacements['ACCENT'])"/>
  <rect x="0" y="20" width="20" height="20" fill="$($Replacements['STATUS_DOWNLOADING'])"/>
  <rect x="20" y="20" width="20" height="20" fill="$($Replacements['STATUS_UPLOADING'])"/>
  <rect x="40" y="20" width="20" height="20" fill="$($Replacements['STATUS_PAUSED'])"/>
  <rect x="60" y="20" width="20" height="20" fill="$($Replacements['STATUS_ERROR'])"/>
</svg>
"@
        Set-Content -Path $SvgPath -Value $SvgContent -Encoding UTF8
    }

    $TempParams = @{ Path = [System.IO.Path]::GetTempPath(); Prefix = "qbt_build_" }
    # Create a temp dir; ensuring valid path
    $TempDir = Join-Path ([System.IO.Path]::GetTempPath()) ([System.Guid]::NewGuid().ToString())
    New-Item -ItemType Directory -Force -Path $TempDir | Out-Null

    try {
        # 2. Build Qt Theme
        if (-not $NoQt) {
            Write-Host "  -> Building Qt client theme (.qbtheme)" -ForegroundColor Gray
            
            # Process templates
            $QssContent = Get-Content (Join-Path $TemplateDir "stylesheet.qss.template") -Raw
            Apply-Replacements $QssContent | Set-Content (Join-Path $TempDir "stylesheet.qss") -Encoding UTF8

            $ConfigContent = Get-Content (Join-Path $TemplateDir "config.json.template") -Raw
            Apply-Replacements $ConfigContent | Set-Content (Join-Path $TempDir "config.json") -Encoding UTF8

            # Handle Icons
            $IconsSrc = Join-Path $TemplateDir "icons"
            $IconsDst = Join-Path $TempDir "icons"
            if (Test-Path $IconsSrc) {
                New-Item -ItemType Directory -Force -Path $IconsDst | Out-Null
                Get-ChildItem $IconsSrc | ForEach-Object {
                    if ($_.Extension -eq ".svg") {
                        $SvgIcon = Get-Content $_.FullName -Raw
                        Apply-Replacements $SvgIcon | Set-Content (Join-Path $IconsDst $_.Name) -Encoding UTF8
                    } else {
                        Copy-Item $_.FullName $IconsDst
                    }
                }
            }

            # Create resources.qrc
            $QrcLines = @(
                "<!DOCTYPE RCC><RCC version=`"1.0`">",
                "  <qresource>",
                "    <file>stylesheet.qss</file>",
                "    <file>config.json</file>"
            )

            if (Test-Path $IconsDst) {
                $IconFiles = Get-ChildItem $IconsDst -Recurse -File
                foreach ($icon in $IconFiles) {
                    # Get relative path for qrc
                    $RelPath = $icon.FullName.Substring($TempDir.Length + 1).Replace("\", "/")
                    $QrcLines += "    <file>$RelPath</file>"
                }
            }
            
            $QrcLines += "  </qresource>"
            $QrcLines += "</RCC>"
            
            Set-Content -Path (Join-Path $TempDir "resources.qrc") -Value $QrcLines -Encoding UTF8

            # Run RCC
            $QbtOutput = Join-Path $OutputDirQt "$ThemeName.qbtheme"
            Push-Location $TempDir
            try {
                & rcc "resources.qrc" -o "output.qbtheme" -binary
                if ($LASTEXITCODE -eq 0) {
                   Move-Item "output.qbtheme" $QbtOutput -Force
                   Write-Host "     -> Created: $QbtOutput" -ForegroundColor Green
                } else {
                   Write-Error "rcc failed with exit code $LASTEXITCODE"
                }
            } finally {
                Pop-Location
            }
        }

        # 3. Build WebUI Theme
        if (-not $NoWebUI) {
            Write-Host "  -> Building WebUI theme (.zip)" -ForegroundColor Gray
            
            $WebUIBuildDir = Join-Path $TempDir "webui-$ThemeName"
            New-Item -ItemType Directory -Force -Path $WebUIBuildDir | Out-Null
            
            # Copy template content recursively
            Copy-Item -Path "$TemplateWebUIDir\*" -Destination $WebUIBuildDir -Recurse -Force

            # Translations folder is retained. 
            # Note: The usage of .ts vs .qm files depends on the qBittorrent backend capabilities.
            # Some embedded versions might require .qm files in /usr/share/qbittorrent/translations.
            
            # Auto-rename qbittorrent_*.qm to webui_*.qm in the build output
            # This allows users to drop in official qBittorrent translation files directly.
            $TransBuildDir = Join-Path $WebUIBuildDir "translations"
            if (Test-Path $TransBuildDir) {
                Get-ChildItem -Path $TransBuildDir -Filter "qbittorrent_*.qm" | ForEach-Object {
                    $NewName = $_.Name.Replace("qbittorrent_", "webui_")
                    $NewPath = Join-Path $TransBuildDir $NewName
                    Write-Host "     -> Renaming $($_.Name) to $NewName" -ForegroundColor DarkGray
                    Move-Item -Path $_.FullName -Destination $NewPath -Force
                }
            }



            # Apply replacements to theme.css
            $CssTemplate = Join-Path $WebUIBuildDir "private\css\theme.css.template"
            if (Test-Path $CssTemplate) {
                $CssContent = Get-Content $CssTemplate -Raw
                Apply-Replacements $CssContent | Set-Content (Join-Path $WebUIBuildDir "private\css\theme.css") -Encoding UTF8
                Remove-Item $CssTemplate
            }

            # Zip it
            $ZipOutput = Join-Path $OutputDirWebUI "webui-$ThemeName.zip"
            if (Test-Path $ZipOutput) { Remove-Item $ZipOutput }
            
            Compress-Archive -Path "$WebUIBuildDir" -DestinationPath $ZipOutput -Force
            Write-Host "     -> Created: $ZipOutput" -ForegroundColor Green
        }

    } finally {
        # Cleanup
        if (Test-Path $TempDir) { Remove-Item $TempDir -Recurse -Force -ErrorAction SilentlyContinue }
    }
}

# Main Execution
if ($ThemeFile) {
    Build-Theme -JsonPath $ThemeFile
} else {
    $ThemeFiles = Get-ChildItem (Join-Path $BaseDir "themes") -Filter "*.json"
    foreach ($Theme in $ThemeFiles) {
        Build-Theme -JsonPath $Theme.FullName
    }
}

Write-Host "`nDone." -ForegroundColor Cyan
