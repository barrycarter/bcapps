#!/bin/perl

# Wraps pocketsphinx_continuous to convert MP3 to audio

# TODO: use pocketsphinx_batch or something instead

require "/usr/local/lib/bclib.pl";

# TODO: don't hardcode tmpdir

my($tmpdir) = "/tmp/bcsw";
chdir($tmpdir)||die("Can't chdir $tmpdir, $!");
my($out,$err,$res);

for $i (@ARGV) {

  my($fname) = $i;
  $fname=~s/^.*\///;

  # convert mp3 to wav
  # TODO: change cache timeout for production
  # TODO: don't test for file existence, only for testing

  unless (-f "$fname.wav") {
    ($out, $err, $res) = cache_command2("ffmpeg -i $i -acodec pcm_s16le -ar 16000 $fname.wav", "age=3600");
  }

  unless (-f "$fname.txt") {
    ($out, $err, $res) = cache_command2("pocketsphinx_continuous -time yes -infile $fname.wav -logfn debug.log > $fname.txt", "age=3600");
  }

  # clean up results
  my($all) = read_file("$fname.txt");

  # this converts newlines to spaces so my trimming below works properly
  $all=~s/\s/ /sg;
  $all=~s/<.*?>//g;
  $all=~s/ [\d\.]+ / /g;

  debug("ALL: $all");

}
