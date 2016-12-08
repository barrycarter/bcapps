# these are modules that yum apparently wont install from any of the
# "approved" repositories

# TODO: this requires user intervention for first setup, perhaps pipe
# "yes yes" to it or something? (or even yes with CR if possible) [this may not work, see next note]

# Choose "sudo" for install method to make it globally available

cpan Statistics::Distributions Astro::Nova Astro::MoonPhase

# TODO: Would you like me to append that to /root/.tcshrc now? (ok,
# but need to tweak in general)
