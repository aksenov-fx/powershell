<# 

.DESCRIPTION

A script to parse values from clipboard to SQL format. 

Input:
    Value1
    Value2

Output:
    'Value1',
    'Value2'
#>

#-------------------------------------------------------------------------------------------------------------#

#1. Define function to get clipboard contents

. $PSScriptRoot\Get-ValuesFromClipboard.ps1

#2. Get clipboard

    Set-Clipboard "empty"
    $Values = @()
    $Values = @(Get-ValuesFromClipboard)

#3. Parse values

    $Values = @($Values.Where{$_ -ne "" })
    $QueryValues = ForEach ($Value in $Values) {"'$Value'"}
    $QueryValues = $QueryValues -join ",`n"

#4. Set Clipboard

    Set-Clipboard $QueryValues