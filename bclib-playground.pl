sub recent_forecast {
  my($options) = ();
  my($cur,$date,$time);
  my(@hrs);
  my(%rethash);

  # there does not appear to be a compressed form
  # guidances are for 6h, so 1h cache is fine
  my($out,$err,$res) = cache_command("curl http://nws.noaa.gov/mdl/forecast/text/avnmav.txt", "age=3600");
#  debug($out);

  # TODO: can X/N sometimes be N/X (and does it give order of high/low?)

  for $i (split(/\n/,$out)) {
    # multiple spaces only for formatting, so I dont need them
    $i=~s/\s+/ /isg;
    # station name and date of "forecast"
    if ($i=~/^\s*(.*?) GFS MOS GUIDANCE (.*?) (.*?) UTC/) {
      # $cur needs to live outside this loop
      ($cur, $date, $time) = ($1,$2,$3);
      $rethash{$cur}{date} = $date;
      $rethash{$cur}{time} = $time;
      next;
    }

    # list of guidance hours (this doesn't really change per station, but...)
    if ($i=~s/^\s*hr\s*//i) {@hrs = split(/\s+/,$i); next;}

    debug("HOURS:",@hrs);



    # TODO: split and return as list? determine hi from lo?
    # TODO: deal w 999s here or elsewhere?
    if ($i=~m%^\s*(X/N|N/X) (.*?)$%) {
      $rethash{$cur}{dir} = $1;
      $rethash{$cur}{hilo} = $2;
      next;
    }
  }

  return %rethash;
}

1;
