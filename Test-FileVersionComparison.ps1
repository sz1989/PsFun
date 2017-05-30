function Test-FileVersionComparison($src, $dest) {
    if (!(Test-Path $dest)) { return $true }

    $srcVer = (gi $src).VersionInfo
    $destVer = (gi $dest).VersionInfo

    if ($srcVer.FileMajorPart -gt $destVer.FileMajorPart) { return $true }
    if ($srcVer.FileMinorPart -gt $destVer.FileMinorPart) { return $true }
    if ($srcVer.FileBuildPart -gt $destVer.FileBuildPart) { return $true }
    if ($srcVer.FilePrivatePart -gt $destVer.FilePrivatePart) { return $true }
    return $false
}

$fileN = 'bin\Ag.SharePoint.DLL'
$srcF = Join-Path (Split-Path $MyInvocation.MyCommand.Definition) $fileN
$destF = Join-Path $OctopusParameters['Octopus.Action.Package.CustomInstallationDirectory'] $fileN
if (!(Test-FileVersionComparison $srcF $destF)) {
    Write-Host "Remove $($srcF)"
    del $srcF
}
