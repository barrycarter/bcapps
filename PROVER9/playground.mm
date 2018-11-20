$( metamath stuff $)

$( Declare the constant symbols we will use $)
$c 0 + = -> ( ) term wff |- $.
$( Declare the metavariables we will use $)
$v t r s P Q $.
$( Specify properties of the metavariables $)
tt $f term t $.

tr $f term r $.
ts $f term s $.
wp $f wff P $.
wq $f wff Q $.
$( Define "term" and "wff" $)
tze $a term 0 $.
tpl $a term ( t + r ) $.
weq $a wff t = r $.
wim $a wff ( P -> Q ) $.
$( State the axioms $)
a1 $a |- ( t = r -> ( t = s -> r = s ) ) $.
a2 $a |- ( t + 0 ) = t $.
$( Define the modus ponens inference rule $)
${
min $e |- P $.
maj $e |- ( P -> Q ) $.
mp $a |- Q $.
$}
$( Prove a theorem $)
th1 $p |- t = t $=
$( Here is its proof: $)
tt tze tpl tt weq tt tt weq tt a2 tt tze tpl
tt weq tt tze tpl tt weq tt tt weq wim tt a2
tt tze tpl tt tt a1 mp mp
$.


