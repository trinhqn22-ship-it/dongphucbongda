$domain = "https://dongphucbongda.inaodongphucmrslinh.com"
$directory = "."

$html_files = Get-ChildItem -Path $directory -Filter "*.html"

$sitemap_content = "<?xml version=`"1.0`" encoding=`"UTF-8`"?>`n"
$sitemap_content += "<urlset xmlns=`"http://www.sitemaps.org/schemas/sitemap/0.9`">`n"

foreach ($file in $html_files) {
    if ($file.Name -eq 'index.html') {
        $url = "$domain/"
        $priority = "1.0"
        $changefreq = "daily"
    } elseif ($file.Name -eq 'blog.html') {
        $url = "$domain/" + $file.Name
        $priority = "0.9"
        $changefreq = "weekly"
    } else {
        $url = "$domain/" + $file.Name
        $priority = "0.8"
        $changefreq = "weekly"
    }
    
    $lastmod = $file.LastWriteTime.ToString("yyyy-MM-dd")
    
    $sitemap_content += "  <url>`n"
    $sitemap_content += "    <loc>$url</loc>`n"
    $sitemap_content += "    <lastmod>$lastmod</lastmod>`n"
    $sitemap_content += "    <changefreq>$changefreq</changefreq>`n"
    $sitemap_content += "    <priority>$priority</priority>`n"
    $sitemap_content += "  </url>`n"
}

$sitemap_content += "</urlset>`n"

$outPath = Join-Path -Path $directory -ChildPath "sitemap.xml"
[System.IO.File]::WriteAllText($outPath, $sitemap_content, [System.Text.Encoding]::UTF8)

Write-Host "sitemap.xml generated successfully."
