(*

Let's see if we can find an **approximate** formula for where on Earth
the Sun is overhead (ie, the "subsolar" point).

Let $t$ be the number of days since the last spring equinox, $y$ be
the number of days in a year (about 365.2425 days), and $\epsilon$ be
the obliquity of the ecliptic (about 23.44 degrees). We will subsitute
in numbers for $y$ and and $\epsilon$ later.

The declination of the sun follows (roughly) a sine wave over the
year, so we can estimate the solar declination as:

$\epsilon  \sin \left(\frac{2 \pi  t}{y}\right)$

This is also the latitude where the sun will be overhead.

The sun's right ascension increases linearally (very roughly
speaking), and we can estimate it in radians as:

$2 \pi  t$

Since the Earth rotates, the longitude of the subsolar point changes
with time: it completes a 360 degree (2 pi radians) circle
approximately every 24 hours.

Since we're approximating, let's assume the spring equinox occurred at
exactly noon UTC (which introduces an error of up to 12 hours).





TODO: ask someone to improve

TODO: equation of time and no need for RA since we measure time by the sun





Since we're
approximating, let's also assume the spring equinox occurred exactly
at Greenwich noon.
