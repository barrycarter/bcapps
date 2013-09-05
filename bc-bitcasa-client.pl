#!/bin/perl

# attempt to create a bitcasa client using their web interface (too
# impatient for them to release Developer API)

require "/home/barrycarter/bc-private.pl";
require "/usr/local/lib/bclib.pl";

# TODO: figure out expiration time of csrf_token and code
my($out,$err,$res) = cache_command2("curl -b cookies.txt -c cookies.txt 'https://my.bitcasa.com/login?redirect=https%3A%2F%2Fmy.bitcasa.com%2F&interface=mobile#/login?redirect=https:%2F%2Fmy.bitcasa.com%2F&interface=mobile'", "age=86400");

# find the csrf_token and code
my(%hash);
my(@post);
while ($out=~s/<input type="hidden" name="(.*?)" value="(.*?)"//) {
  $hash{$1} = $2;
  push(@post,"$1=$2");
}

my($post) = join("&",@post);

# post to form
# TODO: cookies.txt should NOT be in current directory
my($cmd) = "curl -L -b cookies.txt -c cookies.txt -d 'user=$bitcasa{user}&password=$bitcasa{pass}&$post' 'https://my.bitcasa.com/login?client_id=None&redirect=https://my.bitcasa.com/&interface=mobile'";
($out,$err,$res) = cache_command2($cmd);

debug("OUT: $out");

# debug("OUT: $out");

=item comment

https://my.bitcasa.com/login?client_id=None&redirect=https://my.bitcasa.com/&interface=mobile
https://my.bitcasa.com/login?client_id=None&redirect=https://my.bitcasa.com/&interface=mobile

          <input type="hidden" name="csrf_token" value="4440900434674a9a8a7515aefb8e4efe"/>
          <input type="hidden" name="code" value="2d4293fdb92a4e44a3b2bddeeb9b176b"/>
          <input type="hidden" name="redirect" value="https://my.bitcasa.com/"/>


=cut
