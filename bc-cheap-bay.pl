#!/usr/bin/perl

# Finds cheap items on eBay

push(@INC,"/usr/local/lib");
require "bclib.pl";

# TODO: include start/end timestamp generation
# TODO: compress identical listings
# TODO: turn this into a webapp, let $maxprice/$hours be arguments, much more

# Put your own application id in /usr/local/etc/ebay.id
$appid = suck("/usr/local/etc/ebay.id");
$appid=~s/\n//isg;

# settings
$maxprice = 0.01;
# item must end less than this many hours in the future
$hours = 4;

# calculate end time
$endtime=strftime("%FT%TZ",gmtime(time()+$hours*3600));

# URLs for top-level eBay categories; I found these by hand since I
# couldn't get GetCategories to work

@urls = (
"http://video-games.shop.ebay.com/Video-Games-/1249/i.html", 
"http://everythingelse.shop.ebay.com/Everything-Else-/99/i.html", 
"http://travel.shop.ebay.com/Travel-/3252/i.html", 
"http://toys.shop.ebay.com/Toys-Hobbies-/220/i.html", 
"http://tickets.shop.ebay.com/Tickets-/1305/i.html", 
"http://stamps.shop.ebay.com/Stamps-/260/i.html", 
"http://sports-cards.shop.ebay.com/Sports-Mem-Cards-Fan-Shop-/64482/i.html", 
"http://sporting-goods.shop.ebay.com/Sporting-Goods-/382/i.html", 
"http://services.shop.ebay.com/Specialty-Services-/316/i.html", 
"http://realestate.shop.ebay.com/Real-Estate-/10542/i.html", 
"http://pottery-glass.shop.ebay.com/Pottery-Glass-/870/i.html", 
"http://pet-supplies.shop.ebay.com/Pet-Supplies-/1281/i.html", 
"http://instruments.shop.ebay.com/Musical-Instruments-/619/i.html", 
"http://music.shop.ebay.com/Music-/11233/i.html", 
"http://jewelry.shop.ebay.com/Jewelry-Watches-/281/i.html", 
"http://home.shop.ebay.com/Home-Garden-/11700/i.html", 
"http://health-beauty.shop.ebay.com/Health-Beauty-/26395/i.html", 
"http://gift-certificates.shop.ebay.com/Gift-Certificates-/31411/i.html", 
"http://entertainment-memorabilia.shop.ebay.com/Entertainment-Memorabilia-/45100/i.html", 
"http://electronics.shop.ebay.com/Electronics-/293/i.html", 
"http://motors.shop.ebay.com/Cars-Trucks-/6001/i.html", 
"http://dvd.shop.ebay.com/DVDs-Movies-/11232/i.html", 
"http://dolls.shop.ebay.com/Dolls-Bears-/237/i.html", 
"http://crafts.shop.ebay.com/Crafts-/14339/i.html", 
"http://computers.shop.ebay.com/Computers-Networking-/58058/i.html", 
"http://collectibles.shop.ebay.com/Collectibles-/1/i.html", 
"http://coins.shop.ebay.com/Coins-Paper-Money-/11116/i.html", 
"http://clothing.shop.ebay.com/Clothing-Shoes-Accessories-/11450/i.html", 
"http://cell-phones.shop.ebay.com/Cell-Phones-PDAs-/15032/i.html", 
"http://business.shop.ebay.com/Business-Industrial-/12576/i.html", 
"http://books.shop.ebay.com/Books-/267/i.html", 
"http://baby.shop.ebay.com/Baby-/2984/i.html", 
"http://photography.shop.ebay.com/Cameras-Photo-/625/i.html", 
"http://art.shop.ebay.com/Art-/550/i.html", 
"http://antiques.shop.ebay.com/Antiques-/20081/i.html"
);

map {m%/(\d+)/i.html$%; $_=$1} @urls; # extract category numbers
@cats = sort {$a <=> $b} @urls; # don't really need this, but I like it

for $i (@cats) {
  $cmd = "curl -s 'http://svcs.ebay.com/services/search/FindingService/v1?OPERATION-NAME=findItemsAdvanced&SERVICE-VERSION=1.0.0&SECURITY-APPNAME=$appid&RESPONSE-DATA-FORMAT=XML&REST-PAYLOAD=true&paginationInput.entriesPerPage=200&itemFilter(0).name=MaxPrice&itemFilter(0).value=$maxprice&itemFilter(0).paramName=Currency&itemFilter(0).paramValue=USD&itemFilter(1).name=FreeShippingOnly&itemFilter(1).value=true&itemFilter(2).name=EndTimeTo&itemFilter(2).value=$endtime&itemFilter(3).name=ListingType&itemFilter(3).value=Auction&categoryId=$i&sortOrder=BidCountFewest' | tidy -q -xml";
  debug("COMMAND: $cmd");
  # expensive to run above, so cache results for 30m
  # need fixed cachefile since endtime changes slightly each time
  # need ignoreerror here due to this curl error:
  # "line 1 column 109182 - Warning: replacing invalid character code 151"
  $outfile = cache_command($cmd,"age=1800&retfile=1&cachefile=/tmp/ebay-tidy-cat-$i-hours-$hours-maxprice-$maxprice&ignoreerror=1");
  # TODO: check for errors excluding the one above
}

# look at output
for $i (glob "/tmp/ebay-tidy-cat-*-hours-$hours-maxprice-$maxprice") {
  # ignore err/res files
  if ($i=~/\.(err|res)$/) {next;}
  # find items
  debug("FILE: $i");
  $all=suck($i);
  push(@items,($all=~m%<item>(.*?)</item>%sg));
}

# and now, parse items
for $i (@items) {
  %hash=();

  # this isn't 100% but good enough for us
  $j=$i; # just to avoid messing up our loop var
  while ($j=~s%<([^<>]*?)>([^<>]*?)</\1>%%s) {
    ($key,$val) = ($1,$2);
    $val=~s/\s+/ /isg;
    $hash{lc($key)}=trim($val);
  }

  # ignore stuff w/ bidcounts
  if ($hash{bidcount}) {next;}

  print "$hash{itemid} $hash{title}\n";

}
