# these are commands the user can call


sub command_time {

  my($hashref) = @_;

  # TODO: look at hashref vals
  return str2hashref("time=".time());

}

return 1;
