#!/bin/perl

require "/usr/local/lib/bclib.pl";

my(@conf) = split(/\n/, read_file("/home/user/COVID-19/csse_covid_19_data/csse_covid_19_time_series/time_series_covid19_confirmed_US.csv"));

my($hashlist) = arraywheaders2hashlist([map($_=[csv($_)], @conf)]);

for $i (@$hashlist) {
    debug(%$i);
}

# my($hashlist) = arraywheaders2hashlist(\@conf);

# debug(@hashlist);

die "TESTING";


my(@reclist);

for $i (@conf) {
    my(@cols) = csv($i);
    push(@reclist, \@cols);
}



debug(@{$hashlist});

die "TESTNG";



# my($hashlist) = arraywheaders2hashlist(\@conf);

for $i (@{$hashlist}) {

#    debug(keys %{$i});

#    for $j (keys %{$i}) {
#	debug("I: $i, J: $j, VAL: $i{$j}");
#    }

}

# debug(@{$hashlist});

# debug(csv($conf[5]));

# $conf[5] = \@{csv($conf[5])};

# debug("<START>", $conf[5], "<END>");

# debug(@conf);

# my($confs) = arraywheaders2hashlist(\@conf);

# my(@confs) = @{$confs};

# for $i (@confs) {

#    debug(%$i);

#    for $j (keys (%{$i})) {
#	debug("I: $i, J: $j");
#    }
# }


