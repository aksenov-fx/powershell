function Get-ValuesFromClipboard () {

    Write-Host "Please copy values to clipboard"

    $current += @(Get-Clipboard)

    while ($true) {
        Start-Sleep -Milliseconds 500
        $new = @() ; $new += Get-Clipboard
        if ($new[0] -ne $current[0]) {Write-Host $new; return $new}
    }
}