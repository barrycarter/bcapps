# test blog

EDITOR=emacs; export EDITOR; wp --ssh=barrycar@bc4 --path=public_html/test20171209.barrycarter.org post edit 2

exit;

# test blog

wp --ssh=barrycar@bc4 --path=public_html/test20171209.barrycarter.org --fields=ID,post_title,post_name,post_date,post_status,post_author,post_parent,post_type,filter,guid,menu_order,post_content,post_category --format=yaml post list

exit;

wp --ssh=barrycar@bc4 --path=public_html/wordpress --fields=ID,post_title,post_name,post_date,post_status,post_author,post_parent,post_type,filter,guid,menu_order,post_content,post_category --format=yaml post list

exit;

# download all post info on my site

wp --ssh=barrycar@bc4 --path=public_html/wordpress --fields=ID,post_title,post_name,post_date,post_status,post_author,post_parent,post_type,filter,guid,menu_order,post_content --format=yaml post list
