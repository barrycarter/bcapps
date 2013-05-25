=item cache_command2($command, $options)

version 2: write name of command to file and use /var/tmp and multiple
levels of subdirectories to avoid filling /tmp and making it too
large. However, I broke several features when upgrading this function
(commented out options are broken in this version)

Runs $command and returns stdout, stderr, and exit status. If command
was run recently, return cached output. $options:

 salt=xyz: store results in file determined by hashing command w/ salt
 (useful if running multiple instances of the same command)

 age=n: if output file is less than n seconds old + no error, return cached

 fake=1: dont run the command at all, just say what would be done

# retry=n: retry command n times if it fails (returns non-0)
# sleep=n: sleep n seconds between retries
 # TODO: documentation for nocache below is wrong
# nocache=1: dont really cache the results (also global --nocache)
# retfile=1: return the filename where output is cached, not output itself
# cachefile=x: use x as cachefile; dont use hash to determine cachefile name
# ignoreerror: assume return code from command is 0, even if its not

=cut

sub cache_command2 {
  my($command,$options) = @_;

  my(%opts) = parse_form($options);

  # TODO: global nocache means don't *USE* cached results
  # TODO: local nocache would mean don't CREATE cached results

  # determine "name" of tmpfile
  my($file) = sha1_hex("$opts{salt}$command$opts{salt}");
  # split into two levels of subdirs
  $file=~m/^(..)(..)/;
  my($d1,$d2) = ($1, $2);
  # put in /var/tmp/cache
  $file = "/var/tmp/cache/$d1/$d2/$file";
  # make sure dir exists
  unless (-d "/var/tmp/cache/$d1/$d2") {
    system("mkdir -p /var/tmp/cache/$d1/$d2");
  }

  # how old is this file?
  my($fileage) = (-M $file)*86400;

  # if too old (or file doesnt exist), run command and put in $file
  # (or if caching disallowed globally)
  if  (!(-f $file && $fileage < $opts{age}) || $globopts{nocache}) {
    # if fake, just say command would be run
    if ($opts{fake}) {return "NOT CACHED: $command";}

    # otherwise, run command
    my($res) = system("($command) 1> $file-out 2> $file-err");
    my($stdout,$stderr) = (read_file("$file-out"), read_file("$file-err"));
    # delete now unneeded files
    unlink("$file-out","$file-err");
    # write cached results to $file
    write_file(join("\n", (
			   "<cmd>", $command, "</cmd>",
			   "<stdout>", $stdout, "</stdout>",
			   "<stderr>", $stderr, "</stderr>",
			   "<status>", $res, "</status>", "\n"
			   )), $file);
    # and return them
    return $stdout, $stderr, $res;
  }

  # reamining case, cached result exists
  # if faking, just indicate cache exists
  if ($opts{fake}) {return "CACHED: $command";}


  # read/parse/return cached value
  my($cached) = read_file($file);

  unless ($cached=~m%^\s*<cmd>(.*?)</cmd>\s*<stdout>(.*?)</stdout>\s*<stderr>(.*?)</stderr>\s*<status>(.*?)</status>\s*$%s) {
    warn "BROKEN CACHE FILE: $file";
    return;
  }

  # bad form to return $2, $3, $4 "as is"?
  my($stdout,$stderr,$res) = ($2,$3,$4);
  return $stdout, $stderr, $res;
}

1;
