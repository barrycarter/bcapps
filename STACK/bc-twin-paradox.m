(*
http://physics.stackexchange.com/questions/9345/how-will-the-twin-paradox-become-for-time-dilation-if-no-acceleration-was-ever

One objection to this problem: if Peter and Michael are twins, they
would've been born in roughly the same inertial frame (even if the
mother accelerated rapidly between the two births, the not-yet-born
twin would still age more slowly).

In order for them to have a relative speed of .99c, one or both
must've accelerated at some point in their lives.

To work around this, suppose that, shortly after birth, both were
accelerated in opposite directions (at exactly the same rate of
acceleration) for a long time, and the decelerated (at the exact same
rate) until they were at rest with respect to each other.

Then, they accelerate towards each other until their relative speed is
.99c, at which point they stop accelerating and are both in an
inertial (non-accelerating) reference frame. I realize this isn't
exactly the question you posed, but hope my answer will answer your
question as well.

Since they both accelerated the same amount, they are now the same
age, say 20. We will call this year zero.

For convenience, I'm going to change .99c to ~.995c so the time
dilation factor is 10.

Because the twins meet after 30 years, they start off 30*.995 or 29.85
light years apart.

Michael (who considers himself stationery since he's in an inertial
reference frame) keeps an yearly diary:

  - Year 0: I am 20, Peter is 20, Peter is 29.85 light years away. It
  will take Peter's image (aged 20) 29.85 years to get to me, so I
  will see age 20 Peter at Year 29.85.

  - Year 1: I am 21, Peter is aging at 1/10th my speed and thus
  20.1. Peter has traveled .995 light years in the past year, and is
  thus 28.855 light years away. I will see Peter's image (aged 20.1)
  in 28.855 years, and it's Year 1 now, so that will be Year 29.855

  - Year 2: I am 22, Peter is aging at 1/10th my speed and thus
  20.2. Peter has traveled .995 light years in the past year, and is
  thus 27.86 light years away. I will see Peter's image (aged 20.2)
  in 27.86 years, Year 29.86.

  - Year n (n<30): I am 20+n, Peter ages 1/10th as fast and is thus
  20+n/10. Peter travels .995 light years per year, and is thus
  29.85-.995*n light years away. I will see Peter (age 20+n/10) in
  n+29.85-.995*n years.

NOTES:

ages 3 years in .15 years or 20x normal

first see each other 29.85 years after start when they are 0.3 ly apart

*)

age[n_] = 20+n/10
when[n_] = n+29.85-.995*n


Plot[{age[n],when[n]},{n,0,30}]


