[xml]$file = Get-Content 'C:\temp\Ag.Sql.Deployment.nuspec'
foreach($f in $file.package.files.file)
{
    if ($f.src.StartsWith('scripts\',1)) 
    {
        Write-Host $f.src
        $arr = $f.src.Split('.', [System.StringSplitOptions]::RemoveEmptyEntries)
        $arr[$arr.lenght - 2] = $arr[$arr.lenght - 2] + 'abc'
        $newName = $arr -join '.'
        Write-Host $newName
        $f.SetAttribute('target',$newName)
    }
}

$file.Save('C:\temp\a.xml')

<# xml]$file = Get-Content 'C:\temp\Ag.Sql.Deployment.nuspec'
$file.package.files.file | Where-Object { $_.src.StartsWith('scripts\',1) -eq  } | %{
    Write-Host $f.src
}

.\Parse_XML.ps1 -pathToSearch 'C:\temp\MyMy' -buildNumber 'Sql Deployment Publish Build_1.0.0.1'
#> 
