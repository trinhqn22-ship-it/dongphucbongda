import feedparser
import datetime
import urllib.request
import re
import os

# RSS feeds from VnExpress, Tuoi Tre, Tien Phong
RSS_FEEDS = [
    "https://vnexpress.net/rss/the-thao.rss",
    "https://tuoitre.vn/rss/the-thao.rss",
    "https://tienphong.vn/rss/the-thao-11.rss"
]

def fetch_sports_news():
    news_items = []
    
    for url in RSS_FEEDS:
        try:
            feed = feedparser.parse(url)
            for entry in feed.entries[:2]: # Get top 2 from each source
                title = entry.title
                link = entry.link
                summary_clean = re.sub(r'<[^>]+>', '', entry.description)
                
                # Try finding image in description or use a generic one
                image_url = 'https://images.unsplash.com/photo-1579952363873-27f3bade9f55?q=80&w=600&auto=format&fit=crop'
                img_match = re.search(r'<img[^>]+src="([^">]+)"', entry.description)
                if img_match:
                    image_url = img_match.group(1)
                
                news_items.append({
                    'title': title,
                    'link': link,
                    'summary': summary_clean[:150] + '...',
                    'image': image_url,
                    'published': datetime.datetime.now().strftime("%d/%m/%Y, %H:%M AM")
                })
        except Exception as e:
            print(f"Error fetching {url}: {e}")
            
    return news_items[:3] # We return top 3 combined

def generate_blog_html(news_items):
    html_items = []
    for item in news_items:
        html = f"""
        <article class="blog-card">
          <img src="{item['image']}" alt="{item['title']}">
          <div class="blog-content">
            <div class="blog-date">
              <svg width="16" height="16" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M8 7V3m8 4V3m-9 8h10M5 21h14a2 2 0 002-2V7a2 2 0 00-2-2H5a2 2 0 00-2 2v12a2 2 0 002 2z"></path></svg>
              {item['published']}
            </div>
            <h3>{item['title']}</h3>
            <p>{item['summary']}</p>
            <a href="{item['link']}" target="_blank" class="read-more-btn">Đọc Tiếp <svg width="20" height="20" fill="none" stroke="currentColor" stroke-width="2" viewBox="0 0 24 24"><path stroke-linecap="round" stroke-linejoin="round" d="M17 8l4 4m0 0l-4 4m4-4H3"></path></svg></a>
          </div>
        </article>
        """
        html_items.append(html)
    return "\n".join(html_items)

def update_file(filepath, new_html):
    if not os.path.exists(filepath):
        print(f"File {filepath} not found.")
        return
        
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()
    
    # We will replace the content inside <div class="blog-grid" id="blog-grid">
    start_tag = '<div class="blog-grid" id="blog-grid">'
    end_tag = '</div>'
    
    start_idx = content.find(start_tag)
    if start_idx != -1:
        # Find the closing matching div
        end_idx = content.find(end_tag, start_idx)
        if end_idx != -1:
            # We want to replace the inner content of the grid
            new_content = content[:start_idx + len(start_tag)] + "\n" + new_html + "\n      " + content[end_idx:]
            with open(filepath, 'w', encoding='utf-8') as f:
                f.write(new_content)
            print(f"Successfully updated {filepath}")

if __name__ == "__main__":
    print("Fetching sports news...")
    news = fetch_sports_news()
    if news:
        html_snippets = generate_blog_html(news)
        update_file('../blog.html', html_snippets)
        print("Blog updated successfully.")
    else:
        print("No news fetched.")
