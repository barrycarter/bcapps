# these are commands the user can call


sub command_time {

  debug("CALLED!");

  # TODO: look at hash vals
  return str2hashref("time=".time());

}

return 1;
