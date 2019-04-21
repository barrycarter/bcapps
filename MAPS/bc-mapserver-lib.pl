# these are helper functions that the user cannot call directly

# Given a hash where the key cmd represents the command, call the
# relevant use command in bc-mapserver-commands.pl

# NOTE: the hash sent can come from GET or JSON

sub process_command {

  my($hashref) = @_;

  # TODO: delete testing

  $hashref = str2hashref("cmd=fosadfsa");


  # run command
  my($res) = eval("command_$hashref->{cmd}(\$hashref)");

  # check for errors
  my($err) = $@;

  if ($err) {
    return str2hashref("type=error&value=The command **$hashref->{cmd}** does not exist");
  }

  debug("RES: $res, ERR: $@");

  debug(var_dump("res", $res));

}

return 1;
