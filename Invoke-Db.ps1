Param (
    [String]$dbServer = "sqldev3" #$(throw "Specify a db server parameter")
    ,[DateTime]$fromDt = "4/1/2017"
    ,[DateTime]$toDt = "5/1/2017"
    ,[Char]$rptType = 'S'
)

$connectionString = "Server=$dbServer;Integrated Security=SSPI;Initial Catalog=das;"
$connection = New-Object System.Data.SqlClient.SqlConnection
$connection.ConnectionString = $connectionString
$connection.Open()
$command = $connection.CreateCommand()

$query = "DECLARE @return_value int EXEC @return_value = [dbo].[credx_rtg_chg_rpt_trig]
                @from_dt = N'$fromDt', @to_dt = N'$toDt', @rpt_type = N'$rptType'"
$command.CommandText = $query
$command.CommandTimeout = 4200
$adapter = New-Object System.Data.SqlClient.SqlDataAdapter $command
$dataset = New-Object System.Data.Dataset
$adapter.Fill($dataset)
$connection.Close()

# $dataset.Tables[0] | Format-Table -Auto