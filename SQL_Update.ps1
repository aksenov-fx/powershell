<#

.DESCRIPTION

A script to automate a procedure for manual SQL data updates
The script accepts a name of an SQL template file (.sql) as an argument
It uses the template to generate a working SQL script, executes it on a stage (pred) server and outputs the changes

Workflow:
    [0] Set variables and functions
    [1] Get values from clipboard
    [2] Set more variables
    [3] Put text for sending ticket to approval into clipboard
    [4] Make an SQL Script
    [5] Execute SQL script on pred server

#>

#-------------------------------------------------------------------------------------------------------------#
#0. Initialize

Import-Module SqlServer
$ErrorActionPreference = "Inquire"

$SQL_file = $args[0] #Name of SQL scipt template file that will be used to update DB data

#Set vars depending on SQL template file: 
# $SQLServer
# $SQLServerProd
# $Database
# $table
# $entity_name_column
# $output_columns
# $SQL_script_folder
# $approval_request_message

. $PSScriptRoot\Includes\Set_SQL_Update_vars.ps1 $SQL_file
. $PSScriptRoot\Includes\Get-ValuesFromClipboard.ps1

#------------------------------------                                    ------------------------------------#

function Get-Entities($server, $columns) {
    $Query = "SELECT $columns FROM $table where name in ($QueryEntities)"
    Invoke-SqlCmd -ServerInstance "$server" -Database "$Database" -Query "$Query"
    }

#-------------------------------------------------------------------------------------------------------------#
#1. Get values

#[1] Get Entities
    Write-Host `n"Please copy the names of $table entities to clipboard. Format: `
    Value 1`
    Value 2`
    "
    
    $Entities = @()
    $Entities += Get-ValuesFromClipboard
    $Entities = @($Entities.Where{$_ -ne "" })

    $QueryEntities = ForEach ($Entity in $Entities) {"'$Entity'"}
    $QueryEntities = $QueryEntities -join ", "

    Write-Host "Number of Entities in Clipboard:" $Entities.count
    Write-Host "Number of Entities in DB:" @(Get-Entities $SQLServerProd $entity_name_column).count 
    #@ converts object to array for compatibility with PS5, since Invoke-SqlCmd returns different object type than PS7

#[2] Get date
    Write-Host `n"Please copy the date to clipboard. Format: 01.12.2023"
    $Date = Get-ValuesFromClipboard

#[3] Get service desk ticket
    Write-Host `n"Please copy the ticket to clipboard. Format: Ticket-123"
    $Ticket = Get-ValuesFromClipboard
#-------------------------------------------------------------------------------------------------------------#
#2. Set variables

    $DateTime = [DateTime]::ParseExact($Date, "dd.MM.yyyy", $null)
    $SQLDate = $Datetime.ToString("yyyy-MM-dd")

    $FirstEntity = $Entities[0] + "_and_" + ($Entities.Count - 1) + "_others"
    $NewFile = "$scriptName_$($Ticket)_$FirstEntity"

#-------------------------------------------------------------------------------------------------------------#
#3. Set clipboard
    Set-Clipboard $approval_request_message
#-------------------------------------------------------------------------------------------------------------#
#4. Make an SQL Script

    $SQLEntities = ForEach ($Entity in $Entities) {"''$Entity''"}
    $SQLEntities = $SQLEntities -join ", "

    Get-Content "$SQL_script_folder\$SQL_file.sql" | 
        ForEach {$_ -replace 'VarDate', "$SQLDate"} | 
        ForEach {$_ -replace 'VarEntities', "$SQLEntities"} | 
        ForEach {$_ -replace 'VarSDissue', "$ticket"} | 
    Set-Content "$SQL_script_folder\$NewFile.sql"

#-------------------------------------------------------------------------------------------------------------#

#8. Execute SQL script
$Reply = Read-Host -Prompt "Execute script on $SQLServerPred? [y/n]"
if ($Reply -ne 'y') {exit}

Invoke-SqlCmd `
    -ServerInstance "$SQLServerPred" `
    -Database "$Database" `
    -InputFile "$SQL_script_folder\$NewFile.sql"

Get-Entities $SQLServerPred $output_columns | Out-String