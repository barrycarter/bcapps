#!/bin/perl

# A wrapper around grep that searches more the way I want:

# Usage: $0 phrase1 phrase2 phrase3 ... file1 file2 file3 ...

# Does "grep -i phrase1 file1 file2 file3 | grep -i phrase2 | grep -i phrase3"

# In other words, does case-insensitive searching of multiple not
# necessarily adjacent phrases in multiple files (the delination
# between phrases and files is based on whether the given argument is
# an existing file or not).

# Additionally, supports the "include" protocol: if a file "includes"
# another file, the included file is grepped as well, recursively

require "/usr/local/lib/bclib.pl";

