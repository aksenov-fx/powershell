<# 

.DESCRIPTION

A script to parse clipboard values to SQL format like:
Value1 -> 'Value1',
Value2 -> 'Value2'

#>

#-------------------------------------------------------------------------------------------------------------#

#1. Define function to get clipboard contents

    function GetClipboard () {
        Write-Host "Please copy values to clipboard"
        $current += @(Get-Clipboard)
        while ($true) {
            Start-Sleep -Milliseconds 500
            $new = @() ; $new += Get-Clipboard
            if ($new[0] -ne $current[0]) {Write-Host $new; return $new}}}

    #Set-Clipboard "empty"

#2. Get clipboard

    #Write-Host $args

    $Values = @()
    $Values = @(Get-Clipboard)
    #$Values += GetClipboard
    #$Values = $args

#3. Parse values

    $Values = @($Values.Where{$_ -ne "" })
    $QueryValues = ForEach ($Value in $Values) {"'$Value'"}
    $QueryValues = $QueryValues -join ",`n"

#4. Set Clipboard

    Set-Clipboard $QueryValues