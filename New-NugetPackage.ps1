// mimic GIT update
Param(
  [string]$Path = $env:BUILD_SOURCESDIRECTORY
)

ni -ItemType Directory -Force -Path (Join-Path $Path 'packages')
$pathToSearch = Join-Path $Path 'packages\Db.SqlCore.*'
gci $pathToSearch | % {
    ri $_.FullName -Force -Recurse
}

& (Join-Path $Path "Scripts\nuget.exe") @('install', 'Db.SqlCore', '-Source', 'http://octopus:90/nuget/AG', '-OutputDirectory', (Join-Path $Path 'packages'))

$dac = Join-Path $Path 'DacPac'
ni -ItemType Directory -Force -Path $dac   

gci $pathToSearch | sort CreationDate | Select-Object -First 1 | % {
    gci $_.FullName -File -Filter '*.dacpac' | % {
        Write-Host "$($_.FullName)"
        cp $_.FullName $dac -Force
    }
}
