import os
import datetime

domain = "https://dongphucbongda.inaodongphucmrslinh.com"
directory = "."

html_files = [f for f in os.listdir(directory) if f.endswith('.html')]

sitemap_content = '<?xml version="1.0" encoding="UTF-8"?>\n'
sitemap_content += '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n'

for file in html_files:
    if file == 'index.html':
        url = f"{domain}/"
        priority = "1.0"
        changefreq = "daily"
    elif file == 'blog.html':
        url = f"{domain}/{file}"
        priority = "0.9"
        changefreq = "weekly"
    else:
        url = f"{domain}/{file}"
        priority = "0.8"
        changefreq = "weekly"
        
    mtime = os.path.getmtime(os.path.join(directory, file))
    lastmod = datetime.datetime.fromtimestamp(mtime).strftime('%Y-%m-%d')
    
    sitemap_content += '  <url>\n'
    sitemap_content += f'    <loc>{url}</loc>\n'
    sitemap_content += f'    <lastmod>{lastmod}</lastmod>\n'
    sitemap_content += f'    <changefreq>{changefreq}</changefreq>\n'
    sitemap_content += f'    <priority>{priority}</priority>\n'
    sitemap_content += '  </url>\n'

sitemap_content += '</urlset>\n'

with open(os.path.join(directory, 'sitemap.xml'), 'w', encoding='utf-8') as f:
    f.write(sitemap_content)

print("sitemap.xml generated successfully.")
