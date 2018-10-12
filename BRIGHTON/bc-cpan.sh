# these are modules that yum apparently wont install from any of the
# "approved" repositories

# TODO: this requires user intervention for first setup, perhaps pipe
# "yes yes" to it or something? (or even yes with CR if possible) [this may not work, see next note]

# Choose "sudo" for install method to make it globally available

# NOTE: for some reason this doesnt always work at first, but does if
# I re-run it

cpan Statistics::Distributions Astro::Nova Astro::MoonPhase Net::Twitter Net:SSL Finance::Amortization osmDB Image::GeoTIFF::Tiled Geo::ShapeFile Geo::Proj4 Google::ProtocolBuffers XML::Bare Algorithm::GoldenSection FFI::Raw Flickr::API Astro::Coord::ECI::Moon

# below fails
# cpan Google::ProtocolBuffers::Dynamic Alien::ProtoBuf Alien::uPB

# TODO: Would you like me to append that to /root/.tcshrc now? (ok,
# but need to tweak in general)

gem install rubysl-parsedate tk

# and python
# below not working

# python -m pip install OSMpbfParser
