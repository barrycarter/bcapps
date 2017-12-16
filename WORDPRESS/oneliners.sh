# for testing revisions

wp post get 28625 --ssh=barrycar@bc4 --path=public_html/test20171209.barrycarter.org > out6.txt

exit;

fortune | wp post create --ssh=barrycar@bc4 --path=public_html/test20171209.barrycarter.org --post_title="Output of fortune command at `date`" --post_status=publish --post_category=2 --ID=12345 -

exit;

fortune | wp post update 4 - --ssh=barrycar@bc4 --path=public_html/test20171209.barrycarter.org --post_title="Output of fortune command at `date`" --post_status=publish --post_category=2

exit;

# even using an existing id doesn't hurt

fortune | wp post create --ssh=barrycar@bc4 --path=public_html/test20171209.barrycarter.org --post_title="Output of fortune command at `date`" --post_status=publish --post_category=2 --post_id=4 -

exit;

# can't set post_id, but harmless to try

fortune | wp post create --ssh=barrycar@bc4 --path=public_html/test20171209.barrycarter.org --post_title="Output of fortune command at `date`" --post_status=publish --post_category=2 --post_id=1234 -


exit;

# below published live post

fortune | wp post create --ssh=barrycar@bc4 --path=public_html/test20171209.barrycarter.org --post_title="Output of fortune command at `date`" --post_status=publish --post_category=2 -

exit;

# below works to create a post with a category (but still draft?)

fortune | wp post create --ssh=barrycar@bc4 --path=public_html/test20171209.barrycarter.org --post_title="Output of fortune command at `date`" --post-status=publish --post_category=2 -

exit;

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
