# Remvoe extra Word Document from All department sites and plus Remove Word document template from departments site settings-> AG Document Templates group
function Remove-WordDocumentContentType
    (
        [string]$server = "spfarmdev1"
    ) 
{

    Add-PSSnapin Microsoft.SharePoint.Powershell

    $url = "http://" + $server + "/departments"
    Write-Host $url
    $wd = "word document"
    # $ct = Get-ContentTypeFromGroupByName $url "AG Document Templates" -name $wd 
    $ct = ((Get-SPSite $url).RootWeb).ContentTypes | ? { $_.Name.ToLower() -eq $wd }
    if (!$ct) {
        Write-Host "Cannot find content type" $name -ForegroundColor Red
        break
    }

    $web = ((Get-SPWeb $url).Site).allwebs | ?{($_.Url.ToString().ToLower().EndsWith("departmenttemplate") -eq $false)}
    # $web = Get-SPWeb -Identity Dktest -Site http://spfarmdev1/departments
    foreach($w in $web)
    {
          ($w.Lists | ?{ $_.Title.ToLower() -eq "documents" }) | % { 
            Write-Host "--------- Working on" $w.Url "and Document Library" $_.Title
            try {
                if (!$_.ContentTypesEnabled) {
                    $_.ContentTypesEnabled = $true
                    $_.Update()
                }
            
                $rt = $_.RootFolder  
                if ($rt.UniqueContentTypeOrder.Count -eq 0) {
                    $rt.UniqueContentTypeOrder = $rt.ContentTypeOrder
                }

                $currLst = $rt.UniqueContentTypeOrder
                $tmp = $rt.UniqueContentTypeOrder | ? { $_.Name.ToLower() -eq $wd }
                if ($tmp -ne $null) {
                    Write-Host ">>> Hiding" $tmp.Name
                    $currLst.Remove($tmp)
                    $rt.UniqueContentTypeOrder = $currLst
                    $rt.Update()
                }

                $libct = $_.ContentTypes[$wd]
                if ($libct -ne $null) {
                    Write-Host ">>> Deleting" $libct.Name
                    $_.ContentTypes.Delete($libct.Id)
                    $_.Update()
                }
            }
            Catch {
                Write-Host "Cannot Add " $n " into " $lib.Title -ForegroundColor Red
            }
          }  
    }

    try {
        Write-Host ">>------- Finally Working on removing content type" $ct.Name
        $ct.Delete()
    }
    <#
    catch {
        Write-Host $_ErrorRecord
    }
    #>
    finally {
        Write-Host "Disposeing WEB"
        $web.Dispose()    
    }    
}