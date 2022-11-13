# slightly helps convert ../bclib.js to python by replacing
# obj.(something) with obj['something']

if $argv[1] == 1 then

perl -pnle 's/obj\.([a-z]+)/obj[\47$1\47]/sg' ../bclib.js > /tmp/bclib.fu

endif


