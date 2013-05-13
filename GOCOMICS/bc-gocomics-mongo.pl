#!/bin/perl

# attempt to learn mongo using gocomics comments

require "/usr/local/lib/bclib.pl";
@files=glob("/mnt/sshfs/gocomics/comments/*.out.bz2");

for $i (@files) {
  debug("WORKING: $i");
  $all = `bzcat $i`;

  # stolen from bc-gocomics-comments.pl
  while ($all=~s%<ol class='comment-thread'>(.*?)</ol>%%s) {
    # grab comment body (which we do NOT use in hash, BTW)
    $comment = $1;
    %hash = ();

    $hash{filename} = $i;

    # commentor id and name
    $comment=~s%<a href="/profile/(\d+)">(.*?)</a>%%s;
    ($hash{commentorid}, $hash{commentor}) = ($1, $2);

    # strip commented on (and when, tho gocomics gives that in useless format)
    $comment=~s%commented on <a href="/(.*?)/(.*?)/(.*?)/(.*?)">(.*?)</a>\s*<em>(.*?)</em>%%s;
    ($hash{strip}, $hash{yy}, $hash{mo}, $hash{da}, $hash{stripname}, 
     $hash{time}) = ($1, $2, $3, $4, $5, $6);

    # some stripnames have apostrophes; stripping them is easy, but wrong
    $hash{stripname}=~s/\'//isg;

    # body of comment
    $comment=~s%<p><p>(.*?)</p></p>%%s;
    $hash{body} = $1;

    # fix newlines -> breaks
    $hash{body}=~s/\n/<br>/isg;

    # comment id
    $comment=~s%<ul id='comment_(\d+)'>%%;
    $hash{commentid} = $1;

    # added per suggestion of http://stackoverflow.com/questions/16510706/
    $hash{stripid} = "$hash{strip}-$hash{yy}-$hash{mo}-$hash{da}";

    @str = ();
    for $j (sort keys %hash) {
      push(@str,"$j:'$hash{$j}'");
    }
    $str = join(", ",@str);

    # plan to use much faster mongoimport, so no command string
    print "{$str}\n";

#    debug("HASH",%hash);
  }
}



