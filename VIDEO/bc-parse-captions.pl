#!/bin/perl

# fix English captions dl from youtube + maybe do other stuff
# --every=n: create text for screenshots every n seconds (default 10)
# --overwrite: remove and recreate existing directory

require "/usr/local/lib/bclib.pl";

defaults("every=10");

my($data, $fname) = cmdfile();

# find last part of path and associated video prefix

$fname=~m%([^\/]+)\.(.*?)\.(vtt|srt)%;

my($prefix, $lang, $type) = ($1, $2, $3);

if (-d $prefix) {
    if ($globopts{overwrite}) {
	system("rm -rf $prefix");
    } else {
	die("DIRECTORY $prefix already exist");
    }
}

mkdir($prefix);

dodie("chdir('$prefix')");

my($ts, %tran);

$data=~s/<.*?>//sg;

for $i (split(/\n/, $data)) {

    if ($i=~/^\s*$/) {next;}

    if ($i=~/^(\d+):(\d{2}):(\d{2}\.?\d*)\s*\-\->\s*[\d\:\.]+/) {

 	$ts = $1*3600+$2*60+$3;
	next;
    }

    if ($i eq $prev) {next;}

    # mod to nth second
    my($modts) = floor($ts/$globopts{every});

    push(@{$tran{$modts}}, $i);

    $prev = $i;
}

for $i (sort {$a <=> $b} keys %tran) {

    my($fname) = sprintf("tranimg%08d.jpg.txt", $i);

    my($text) = join(" ", @{$tran{$i}});

    write_file($text, $fname);
}

# TODO: make this more accurate

my($frameMod) = $globopts{every}*30;

# TODO: this is really really ugly hardcoding dir

print qq#ffmpeg -i /home/user/YOUTUBE/$prefix.m?? -vf "select=not(mod(n\\,$frameMod))" -vsync vfr $prefix/tranimg%08d.jpg\n#;

# debug(keys(%tran));


# debug($data);

