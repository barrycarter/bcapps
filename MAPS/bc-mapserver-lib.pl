# these are helper functions that the user cannot call directly

# Given a hash where the key cmd represents the command, call the
# relevant use command in bc-mapserver-commands.pl

# NOTE: the hash sent can come from GET or JSON

sub process_command {

  my($hashref) = @_;

  my($cmd) = $hashref->{cmd};

  # error checking

  unless ($cmd) {
    return str2hashref("type=error&value=API request did not have 'cmd' field");}

  # now try to run command_$cmd 

  debug("CMD: $cmd");
  my($eval) = "command_$cmd(\$hashref)";
  debug("EVAL: $eval");
  my($res) = eval($eval);

#  $res = eval(qq%1+5;%);
#  $test = "1+5";
#  $res = eval($test);

  debug("RES: $res, ERR: $@");
  debug(var_dump("res", $res));

}

return 1;
