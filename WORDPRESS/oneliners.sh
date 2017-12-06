# download all post info on my site

wp --ssh=barrycar@bc4 --path=public_html/wordpress --fields=post_author,post_content,post_content_filtered --post_status=publish --posts_per_page=5 --format=json post list
