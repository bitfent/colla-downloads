param([string]$Version = 'latest', [string]$BinDir = "$env:LOCALAPPDATA\Colla\bin")
$ErrorActionPreference = 'Stop'
if (-not [Environment]::Is64BitOperatingSystem) { throw 'Colla requires 64-bit Windows.' }
if ($env:PROCESSOR_ARCHITECTURE -eq 'ARM64') { throw 'This release supports Windows x64. Native Windows ARM64 is not yet verified.' }
if ($Version -eq 'latest') { $base = 'https://github.com/bitfent/colla-downloads/releases/latest/download' }
elseif ($Version -match '^v[0-9]+\.[0-9]+\.[0-9]+([.-][A-Za-z0-9.-]+)?$') { $base = "https://github.com/bitfent/colla-downloads/releases/download/$Version" }
else { throw 'Invalid release version.' }
$asset = 'colla-windows-x64.zip'
$stage = Join-Path ([IO.Path]::GetTempPath()) ([Guid]::NewGuid().ToString())
New-Item -ItemType Directory -Path $stage | Out-Null
try {
    Invoke-WebRequest "$base/$asset" -OutFile (Join-Path $stage $asset)
    Invoke-WebRequest "$base/$asset.sha256" -OutFile (Join-Path $stage 'checksum')
    $expected = ((Get-Content -Raw (Join-Path $stage 'checksum')) -split '\s+')[0]
    $actual = (Get-FileHash (Join-Path $stage $asset) -Algorithm SHA256).Hash
    if ($actual -ne $expected) { throw 'Checksum mismatch; nothing installed.' }
    Expand-Archive (Join-Path $stage $asset) (Join-Path $stage 'unpacked')
    New-Item -ItemType Directory -Force -Path $BinDir | Out-Null
    Copy-Item (Join-Path $stage 'unpacked/colla.exe') (Join-Path $BinDir 'colla.exe') -Force
    $userPath = [Environment]::GetEnvironmentVariable('Path', 'User')
    if (($userPath -split ';') -notcontains $BinDir) { [Environment]::SetEnvironmentVariable('Path', "$userPath;$BinDir", 'User') }
    if (($env:Path -split ';') -notcontains $BinDir) { $env:Path += ";$BinDir" }
    & (Join-Path $BinDir 'colla.exe') --version
    if ($LASTEXITCODE -ne 0) { throw 'Installed binary could not start.' }
    Write-Output "Installed at $BinDir. New terminals can run colla."
} finally { Remove-Item -Recurse -Force $stage }
