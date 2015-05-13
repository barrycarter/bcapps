#!/bin/perl

# Given a FetLife user profile, returns a trimmed version with no loss
# of information, just loss of headers/etc; currently in testing

# will use diff -uwr on old and new versions to confirm loss is
# identical (and thus useless) on each file

require "/usr/local/lib/bclib.pl";

# directory where I am temporarily keeping these files, pending bzdiff
# to originals

my($target) = "/mnt/extdrive/20141229-FET";

for $i (@ARGV) {

  my($all);
  if ($i=~/\.bz2$/) {
    $all = join("", `bzcat $i`);
  } else {
    $all = read_file($i);
  }

  # kill off scripts
  $all=~s%<script[^>]*?>(.*?)</script>%%sg;

  # kill off leading spaces
  $all=~s/^\s+//mg;

  # nothing useful pre-title
  $all=~s/^.*?<title>/<title>/s;

  # everything between that and <h2
  # $all=~s%</title>.*?<h2%</title>\n<h2%s;
  $all=~s%</title>.*?<div class="span-6">%</title>%s;

  # everything past the ads container (nope, past report user)
#  $all=~s%<div id="ads_container">.*$%%s;
  $all=~s%<section id="report_user".*$%%s;

  # kill off lines that have just a single tag with no data (except div)
#  $all=~s%^\s*</?(div|table|tr)[^>]*?>\s*$%%mg;
  $all=~s%^\s*</?(table|tr)[^>]*?>\s*$%%mg;

  # for div, can only kill off pure lines
  $all=~s%^</?div>$%%mg;

  # pure div tags
  $all=~s/<div .*?>//mg;

  # kill off blank lines
  $all=~s/\n+/\n/sg;

  debug("ALL: $all");

  # where I am keeping the revised versions
  debug("I: $i");
  my($j) = $i;
  $j=~s/\.bz2$//;
  $j=~s%^.*/%%;
  $j=~m%(\d{3})(\d+)$%;
  my($dir,$file) = ($1, $2);
  debug("DIRFILE: $dir/$file");

#  debug("ALL IS: $all");

#  unless (-d "$target/$dir") {system("mkdir $target/$dir");}

#  write_file($all, "$target/$dir/$dir$file");

  # bzdiff doesn't support "-r", so leaving these unbzipped for now
  # system("bzip2 $target/$dir/$dir$file");
}

# to test, use "diff -uwr" on two directories (after bunzipping the
# original) and then sort/uniq the results to see which lines show
# multiple times (ie, in each profile)

# NOTE: xizvlcr /users/4672444 is one identity (now deleted) I used to
# obtain data; final result of user4670909.bz2 should contain neither
# of these values

=item comment

Lines in which user id or name appears:

    FetLife.currentUser.id          = 4672444;
    FetLife.currentUser.nickname    = "xizvlcr";
    FetLife.currentUser.profileUrl  = "/users/4672444";
    FetLife.currentUser.updateBrowserDetailUrl = "https://fetlife.com/users/4672444/update_browser_details";
          <a href="#" class="small rcts pulldown-trigger"><span class="nickname">xizvlcr</span><span class="or">&or;</span></a>
            <li class="seperator"><a href="/users/4672444"><span class="picto">U</span>View Your Profile</a></li>
            <li><a href="/users/4672444/friends"><span class="picto">g</span>View Your Friends</a></li>
            <li class="seperator"><a href="/users/4672444/likes_v4"><span class="picto">k</span>Stuff You Love</a></li>
  <a href="/users/4672444/blockeds?blocked_user_id=4670909&amp;redirection_path=/users/4670909" class="btnsqr" data-method="post" data-modal="block" rel="nofollow">Block juicey_L</a>

=cut
