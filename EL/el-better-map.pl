#!/bin/perl

# Attempts to create better maps for EL using el-wiki.net information
# --username=username [if given, colors NPCs based on username's logs]
# --unlinked: look for references to this map that are not linked to map page

# Desert Pines = first example

require "bclib.pl";

# --unlinked is now the default (maps are too incomplete w/o it)
$globopts{unlinked} = 1;

# argument now required
# ($map) = @ARGV;

# unless ($map) {
#  die("Usage: $0 [--username=username] [--unlinked] \"Portland|Desert Pines|other map name\");}

# map maps to ... something
$mapping = read_file("EL/mapmap.txt");

for $i (split(/\n/, $mapping)) {
  $i=~/^(.*?)\s(.*)$/;
  ($fname, $land) = ($1, $2);
  $land=~s/_/ /isg;
  $markfile{$land} = "$fname.elm.txt";
}

# $map = "Tarsengaard";
# $map = "Portland";
# $map = "Valley of the Dwarves";
# $map = "Isla Prima";
# $map = "White Stone";
$map = "Desert Pines";
# $map = "Morcraven Marsh";
# $map = "Crystal Caverns";
# $map = "Grubani Peninsula";
# $map = "Nordcarn";
# $map = "Naralik";
# $map = "Southern Kilaran";
# $map = "Ruins of Tirnym";
# $map = "Port Anitora";
# $map = "Idaloran";

$markfile = $markfile{$map};

unless ($markfile{$land}) {
  die "I don't know how to create a marks file for: $land";
}

# if requested, see what NPCs you've spoken with
# NOTE: assumes NPC in-game name is identical to wiki name, not always true
# NOTE: this won't work if you have multiple chars

if ($globopts{"username"}) {
  $quest = read_file("$ENV{HOME}/.elc/main/quest_$globopts{username}.log");
  for $i (split(/\n/, $quest)) {
    # note that I have seen this NPC (+ how many times)
    $i=~s/:.*$//;
    # this appears in chat logs for some reason
    $i=~s/\x8a//;
    $seen{$i}++;
  }
}

# are there other pages that link to this map but aren't on this map page?

if ($globopts{"unlinked"}) {
  # TODO: the wiki api may have a better way of doing this
  ($res) = cache_command("fgrep -lR '\[\[$map\]\]' /usr/local/etc/wiki/EL-WIKI.NET", "age=3600");
  @res = split(/\n/, $res);
  for $i (@res) {
    $cont = read_file($i);

    # must be in namespace 0
    $cont=~/ns="(\d+)"/;
    if ($1) {next;}

    # determine page title and store title -> page translation
    $cont=~/title="(.*?)"/;
    $title = $1;
    $filename{$title} = $i;


    # what categories is this page in? (ie, NPC?)
    $isnpc = 0;
    while ($cont=~s/\[\[Category:\s*(.*?)\]\]//) {
      if ($1=~/npc/i) {$isnpc=1; last;}
    }

    unless ($isnpc) {next;}

    # do we have coords for this NPC?
    if ($cont=~/at (\[\d+,\d+\])/isg) {
      debug("SETTING COORDS for $title");
      $coords{$title} = $1;
    }

    # this isn't perfect: determine which npcs are linked to
    $islinked{$title} = 1;
  }
}

debug(unfold(%seen));

# find the file where I store Desert Pines wiki page (not super efficient)
# really hard to match <tab> exactly w/o also matching spaces
($res) = cache_command("egrep -i '[[:space:]]$map\$' /usr/local/etc/wiki/EL-WIKI.NET/pageinfo-0.txt", "age=3600");

# find the exact right one
for $i (split(/\n/, $res)) {
  $i=~/^(.*?)\s+(.*?)\s+(.*?)$/;
  ($file, $time, $name) = ($1,$2,$3);
  if ($name eq $map) {last;}
}

$page = read_file("/usr/local/etc/wiki/EL-WIKI.NET/$file");

# TODO: this is a really ugly way of adding non-listed NPCs
$page.="\n === NPC (spec) ===\n";
for $i (sort keys %coords) {
  $page.="[[$i]] - $coords{$i}\n\n";
}

for $i (split("\n",$page)) {
  debug("LINE: $i");

  # are we in a new section?
  if ($i=~/\=\=\= (.*?) \=\=\=/) {$section = $1; next;}

  # does this line have coordinates (maybe more than one)
  @coords = ();
  while ($i=~s/\[(\d+\,\d+)\]//) {
    push(@coords, $1);
  }

  unless (@coords) {
#    debug("No coords, skipping");
    next;
  }

  # ignore [[File:thing]]
  $i=~s/\[\[file:.*?\]\]//isg;

  # look for the first [[thing]]; if none, use first word as name
  if ($i=~/\[\[(.*?)\]\]/) {
    $name = $1;
  } else {
    $name = $i;
    # get rid of external links and *
    $name=~s/\[.*?\]//isg;
    $name=~s/\*//isg;
    $name=~s/\s.*$//;
  }

  # keep track of which pages I've seen
  $ismentioned{$name} = 1;

  for $j (@coords) {
    debug("SECTION: $section");
    # breakdown marks into categories
    if ($section=~/npc/i) {
      $prefix="NPC:";
    } elsif ($section=~/harvest/i) {
      $prefix="H:";
    } else {
      $prefix="";
    }

    # color code (these color choices aren't final)
    debug("NAME: $name, SEEN: $seen{$name}");
    if ($seen{$name}) {
      $color="0,0,0";
    } else {
      $color="255,255,255";
    }

    unless ($name) {
      warnlocal("NO NAME IN: $i");
      next;
    }

    # add to marks file
    $j=~s/,/ /isg;
    push(@marks, "$j|$color| $prefix$name");
  }
}

# NPCs that link to map page, but aren't on map page
@linked = keys %islinked;
@mentioned = keys %ismentioned;
@wanted = minus(\@linked, \@mentioned);

for $i (@wanted) {
  debug("$i $coords{$i} -> $filename{$i}");
}

# intentionally put this in GIT so people can have updated versions
# (kinda) w/o having to run this program [however, my versions may
# contain marks specific to me]

write_file(join("\n",@marks)."\n", "/home/barrycarter/BCGIT/EL/$markfile");

# NOTE: must change maps for new marks file to load (I have it symlinked)
