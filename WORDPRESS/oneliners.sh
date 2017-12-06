# download all post info on my site

wp --ssh=barrycar@bc4 --path=public_html/wordpress --fields=ID,post_title,post_name,post_date,post_status,post_author,post_parent,post_type,filter,guid,menu_order,post_content --posts_per_page=50 --format=yaml post list
