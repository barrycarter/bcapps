#!/bin/perl

=item comment

Converts the output of:

SELECT f.id,
long_desc, nt.name, n.amount FROM food f JOIN nutrition
n ON (f.id = n.food_id) JOIN nutrient nt ON (nt.id = n.nutrient_id)
WHERE nutrient_id IN (
208, 204, 606, 601, 307, 205, 291, 269, 203, 318, 262, 303, 645, 430,
306, 324, 605, 301, 401, 323
);

(in sqlite3 -line form) to INSERT statements for myfoods.db

=cut

require "/usr/local/lib/bclib.pl";

