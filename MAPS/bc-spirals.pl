#!/bin/perl

# Fun with spirals

require "/usr/local/lib/bclib.pl";



=item spiralCoords($n)

If we start at (0,0) in 2D space and traverse a spiral, this returns
the nth step of that spiral

https://stackoverflow.com/questions/9970134/get-spiral-index-from-location

=cut

sub spiralCoords {

  my($n) = @_;






}

=item comments

step 0 is 0 0 = 1 step

first loop takes 3^2 - 1^2 = 8 steps

2nd loop takes 5^2 - 3^2 = 16 steps

3rd loop takes (3*2+1)^2 - (3*2-1)^2 = 24 steps

nth loop takes (n*2+1)^2 - (n*2-1)^2 = 8 n steps

n up, 2n left, 2n down, 2n right, n up

using Mathematica to help

spiral[n_, 1] := Table[{n, i}, {i, 1-n, n}]

spiral[n_, 2] := Table[{i, n}, {i, n-1, -n, -1}]

spiral[n_, 3] := Table[{-n, i}, {i, n-1, -n, -1}]

spiral[n_, 4] := Table[{i, -n}, {i, -n+1, n}]

(* only special case *)

spiral[0] := {{0,0}};

spiral[n_] := Flatten[Table[spiral[n, i], {i,1,4}], 1]

Flatten[Table[spiral[i], {i, 0, 5}], 1]

spiralThru[n_] := Flatten[Table[spiral[i], {i, 0, n}], 1]

first100 = spiralThru[100];

(* we are 0 indexed here *)

first100Indexed := Table[{i, first100[[i+1]]}, {i, 0, Length[first100]-1}];

Transpose[first100][[1]]

first10 = spiralThru[10];

xval[n_] = Interpolation[Transpose[first10][[1]], InterpolationOrder -> 1][n]

Table[xval[n] - Transpose[first10][[1]][[n]], {n, 1, Length[first10]}] confirms perfect fit












copied code:

if y * y >= x * x then begin
  p := 4 * y * y - y - x;
  if y < x then
    p := p - 2 * (y - x)
end
else begin
  p := 4 * x * x - y - x;
  if y < x then
    p := p + 2 *(y - x)
end;













=cut
