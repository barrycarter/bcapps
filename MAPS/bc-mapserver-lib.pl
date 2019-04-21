# these are helper functions that the user cannot call directly

# Given a hash where the key cmd represents the command, call the
# relevant use command in bc-mapserver-commands.pl



sub process_command {

  my($hash) = %{$_[0]};

  my($cmd) = $hash{cmd};

  # error checking

  unless ($cmd) {
    return str2hashref("type=error&value=
