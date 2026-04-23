$html_files = Get-ChildItem -Path . -Filter "*.html"
$redirectScript = "`n  <script>if (location.protocol !== 'https:' && location.hostname !== 'localhost' && location.hostname !== '127.0.0.1') { location.replace(window.location.href.replace('http:', 'https:')); }</script>"

foreach ($file in $html_files) {
    $content = Get-Content $file.FullName -Raw
    if ($content -notmatch "location\.protocol !== 'https:'") {
        $content = $content -replace "<head>", "<head>$redirectScript"
        [System.IO.File]::WriteAllText($file.FullName, $content, [System.Text.Encoding]::UTF8)
    }
}
Write-Host "Added HTTPS redirect to all HTML files."
