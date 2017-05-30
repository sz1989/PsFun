# make sure site content type: "AG Document Templates" is in Departments site collection with only two document templates: Excel Document and PowerPoint Document
param(
    [string]$server = "spfarmdev1"
)

Add-PSSnapin Microsoft.SharePoint.Powershell

$url = "http://" + $server + "/departments"
$newTypes = Get-ContentTypeNames $url "AG Document Templates"
$currTypes = Get-ContentTypeNames $url "AG Document Types"

$web = ((Get-SPWeb $url).Site).allwebs | ?{($_.Url.ToString().ToLower().EndsWith("departmenttemplate") -eq $false)}
# $web = Get-SPWeb -Identity It -Site $url
foreach($w in $web)
{
    ($w.Lists | ?{ $_.Title.ToLower() -eq "documents" }) | % { 
        Write-Host "--------- Working on " $w.Url " and Document Library " $_.Title
        try {
            if (!$_.ContentTypesEnabled) {
                $_.ContentTypesEnabled = $true
                $_.Update()
            }
    
            Add-ContentTypeByNames $_ $newTypes
            Hide-ContentTypeByNames $_ $currTypes
            Show-ContentTypeByNames $_ $newTypes
        }
        Catch {
            Write-Host "Cannot Add " $n " into " $lib.Title -ForegroundColor Red
        }
    }
}
$web.Dispose()

function Get-ContentTypeNames($url, $grp) {
    $ret = @{}
    $rw = ((Get-SPWeb $url).Site).allwebs | ?{($_.IsRootWeb -eq $true)}
    $rw.ContentTypes | ?{ $_.Group -eq $grp } | %{$ret.Add($_.Name,$rw.ContentTypes[$_.Name])}

    if ( $ret.Count -eq 0) {
        Write-Host $grp " is empty" -ForegroundColor Red
        exit 1
    }
    return $ret
}

function Add-ContentTypeByNames($lib, $ctypes) {
    $ctypes.Keys | % {
        $tmp = $lib.ContentTypes[$_]
        if ($tmp -eq $null) {
            $lib.ContentTypes.Add($ctypes.Item($_))
            $lib.Update()
            Write-Host "Add ContentTypes " $_ " into " $lib.Title " Library"
        } 
        else {
            Write-Host $lib.Title " Library has ContentType " $_
        }
    }
}

function Hide-ContentTypeByNames($lib, $ctypes) {
    $rt = $lib.RootFolder  
    if ($rt.UniqueContentTypeOrder.Count -eq 0) {
        $rt.UniqueContentTypeOrder = $rt.ContentTypeOrder
    }
    $currLst = $rt.UniqueContentTypeOrder
    foreach ($n in $ctypes.Keys) {
        Write-Host ">>> Try to Hide " $n
        $tmp = $currLst | ? { $_.Name -eq $n }
        if ($tmp -ne $null){
            Write-Host ">>> Hiding " $tmp.Name
            $currLst.Remove($tmp)  
        }
    }
    $rt.UniqueContentTypeOrder = $currLst 
    $rt.Update()
}

function Show-ContentTypeByNames($lib, $ctypes) {
    $rt = $lib.RootFolder 
    $currLst = $rt.UniqueContentTypeOrder
    foreach ($n in $ctypes.Keys) {
        Write-Host ">>> Try to Show " $n
        $tmp = $currLst | ? { $_.Name -eq $n }
        if ($tmp -eq $null){
            $newCt = $lib.ContentTypes | ?{ $_.Name -eq $n }
            Write-Host ">>> Displaying " $newCt.Name
            $currLst.Add($newCt)
        }
    }
    $rt.UniqueContentTypeOrder = $currLst 
    $rt.Update()
} 