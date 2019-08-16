# run as "ruby $0", not using hashbang

# Text browse OpenStreetMap (OSM)

# Before complaining about the code, please read the README file

# REQUIRES: imagemagick, fly, curl, xv for some/any/all functionality

require "./bclib-temp.rb"

$ZOOM_LEVEL = 16

# directory for cached materials

$MYDIR = "/usr/local/etc/OSM2020"

# generic OSM object (node or way)

class OSMObject

  include Util

  # initalize the object by treating the passed string as a hash, and
  # creating a new empty hash for tags

  def initialize(s)
    setfields(s)
    @tags = Hash.new()
  end

  # add tag k with value v to object

  def add_tag(k,v) @tags[k] = v end

  # TODO: this function probably belongs in Util not here

  # convert degree measure to nice name

  # TODO: perhaps shorten to "E", "NE", "N", etc?

  # NOTE: Duplication of east below is intentional

  def nicedir(x)

    dirs = ["east","northeast","north","northwest","west","southwest","south","southeast","east"]
    dirs[(x%360/45).round]
  end
end

# a node

class Node < OSMObject

  # the short form display of a node is the name, node id, and its
  # distance from the user

  def short
    "#{@tags['name']} (node #{@oid}) is #{@dist.round} meters to your #{nicedir(@dir)}"
  end

  # the long form display just prints out all the tags
  # TODO: improve this!

  def to_s
    "NODE(#{@oid}):\n"+@tags.collect{|i,j| "TAG: #{i} -> #{j}"}.join("\n")
  end

  # Update relative-to-user info for this node

  def relative_info
    @dist = gcdist(@lon, @lat, $USER.LON, $USER.LAT)
    @dir = gcdir($USER.LON, $USER.LAT, @lon, @lat)
  end
  
  # fly commands to display this node inside the containing $ZOOM_LEVEL tile

  def fly(t,width,height)

    # ignore anonymous nodes (anonymous nodes belonging to ways will
    # be displayed in the Way object-- anonymous nodes that don't
    # belong to ways are probably pointless [pun intended])

    if (!@tags['name']) then return end

    x,y = t.xy(@lon,@lat,width,height)

    # draw a small circle and a nearby string giving the node name

    "circle #{x},#{y},2,255,255,0\nstring 255,255,255,#{x},#{y},tiny,#{@tags['name']}"

  end

end

# a way is an array of nodes

class Way < OSMObject

  # mostly the same initialization as OSMObject, but create arrays for
  # nodes and segments (lines connecting two nodes)

  def initialize(s)
    @arr = Array.new()
    @segments = Array.new()
    super
  end

  # short form display of this object is the name, distance, and direction

  # TODO: this really needs to be improved, since the list of nodes in
  # a way doesn't really determine the way's direction; if anything,
  # this should say "runs north-south" instead of "runs north"

  def short
    "#{@tags['name']} (way #{@oid}) runs #{nicedir(@direction)} #{@dist.round} meters to your #{nicedir(@dir)}"
  end

  # long form displays all the tags and the nearest segment
  # TODO: improve this

  def to_s
    tags ="WAY(#{@oid}):\n"+@tags.collect{|i,j| "TAG: #{i} -> #{j}"}.join("\n")
    segs = "NEAREST SEGMENT: #{@order+@t}"
    return tags+"\n"+segs
  end

  # add a node (which automatically creates a new segment)

  def add(n)
    if (@arr.size>0) then 

      # segments know where in the array they are (which is useful)

      (s = Segment.new(@arr[-1],n)).order = arr.size-1
      @segments.push(s)

    end

    # case if there are no nodes at all in the array yet

    @arr.push(n) 

  end

  # update relative-to-user info for this way (which point of this way
  # is closest to user)

  def relative_info

    # update information for each segment of way

    @segments.each{|i| i.relative_info}

    # find which segment is closest to user
    # TODO: sorting here to find min may be excessive
    
    s = @segments.sort_by{|i| i.dist}[0]


    # special case of no segments (empty way)

    if (s.nil?) then 
      @pt, @dist, @dir, @order, @t, @direction = 0,0,0,0,0,0
      return 
    end

    # Copy the information from the nearest Segment to the way
    # TODO: must be a better way to do this

    @pt, @dist, @dir, @order, @t, @direction = 
      s.pt, s.dist, s.dir, s.order, s.t, s.direction

  end
  
  # the fly commands to display this way in a given tile, given width, height
  # TODO: this can probably be improved a lot

  def fly(t,width,height)

    # let the segments draw themselves

    s = segments().collect{|i| i.fly(t,width,height)}.join("\n")

    # now the nodes (TODO: named nodes get displayed twice, probably
    # not a huge deal, but still)
    
    # TODO: should we really display anonymous nodes at all?

    s = "#{s}\n" + (@arr.collect{|i| "circle #{t.xy(i.lon,i.lat,width,height).join(',')},2,0,255,255"}).join("\n")

    # now the way name (displayed on the point nearest user)
    # TODO: displaying on poing nearest user might be too inconsistent

    x,y = t.xy(@pt[0],@pt[1],width,height)

    # TODO: does ruby have an 'ifnil' function like MySQL's IFNULL?

    # if the way is anonymous, assign it an empty string as a name

    name = ((@tags['name'].nil?)?"":@tags['name'])

    # if way runs north-south, print vertically

    # TODO: in either case, center text to nearest point on way (maybe?)

    # NOTE: disabling centered text as it's annoying when two streets cross

    strx,stry = x,y

    if ((@direction/90).round%2==1) then

      strdir = "stringup"

      # fly tiny font is 8 pixels in printed direction(?) [should be 8x5]
      # NOTE: uncomment next line for centered text?
      # strx,stry = x,y+5*name.length/2

    else

      strdir = "string"

      # NOTE: uncomment next line for centered text?
      # strx,stry = x-5*name.length/2,y

    end

    "#{s}\ncircle #{x},#{y},2,255,255,0\n#{strdir} 255,255,255,#{strx},#{stry},tiny,#{name}"

  end

   # given that you're on segment 'cur' on this way (segment 2.7 =
   # 7/10th of the way between nodes 2 and 3) and move dist meters,
   # return new segment position; negative motion is towards lower node numbers

   def travel(cur,dist)

     frac,full = cur%1,cur.floor

     # TODO: using testfrac and frac here seems unclean; is there a better way?
     testfrac = frac

     # TODO: this seems kludgey

     if (cur>=segments.length) then frac,full=1,segments.length-1 end
     if (cur<0) then frac,full=0,0 end

     # TODO: infinite loop here is a bad idea-- basically, we move
     # along segments until we've traveled the distance required

     while 1 do

       # how far along current segment can I move

       testfrac += dist/segments[full].length

       # if I haven't reached start/end of segment, return

       if (testfrac.between?(0,1)) then return full+testfrac end

       # TODO: could probably combine the two 'if' forks below

       # have reached begin/end of segment, so move to next/prev segment

       if testfrac>1 then

	 # I haven't traveled far enough, move to next segment

	 dist -= (1-frac)*@segments[full].length
	 full+=1
	 frac=0
	 testfrac=0

       else

	 # I moved too far, go back to previous segment

	 @segments[full].length
	 dist += frac*@segments[full].length
	 full-=1
	 frac=1
	 testfrac=1

       end

       # TODO: should probably indicate error if either of the below occur

       # I've moved to the end of the way, but still haven't traveled
       # the required amount

       if (full>@segments.length-1) then return @segments.length end

       # I traveled (in a negative direction) beyond the beginning of
       # the way, but still haven't traveled the required amount

       if (full<0) then return 0 end

     end

   end

   # return the longitude/latitude of the point that is on the
   # floor(val)th segment, and frac(val) along that segment (0 = start
   # of segment, 1 = end of segment)

   def segpoint(val) 

     # special cases if floor(val)th doesn't exist on way

     if (val>=@segments.length) then return @segments[-1].partway(1) end
     if (val<0) then return @segments[0].partway(0) end

     @segments[val.floor].partway(val%1) 

   end

end

# a segment (directed line segment between two nodes)

# OSM no longer uses segments(?), but they're still useful internally

# lon1, lat1, lon2, lat2 are the two ends of the segment

class Segment
  include Util

  def initialize(n1,n2)

    @lon1,@lat1,@lon2,@lat2 = n1.lon,n1.lat,n2.lon,n2.lat

    # determine segment length and distance

    # TODO: the use of great circle direction and distance here is
    # probably excessive-- segments are short enough that planar
    # geometry would work fine

    @length = gcdist(@lon1,@lat1,@lon2,@lat2)
    @direction = gcdir(@lon1,@lat1,@lon2,@lat2)

  end

  # Calculate info about this segment relative to user's location

  def relative_info

    # point on the segment closest to user

    # TODO: assuming planar geometry here, that's probably OK?

    # t=0 at lon1,lat1 and t=1 at lon2,lat2

    # TODO: source this formula for finding closest point on segment

    @t = (@lon1**2-@lon1*@lon2+$USER.LON*(@lon2-@lon1)-($USER.LAT-@lat1)*(@lat1-@lat2))/
      ((@lon1-@lon2)**2+(@lat1-@lat2)**2);

    # if 0<t<1, then middle of segment is closest; otherwise, end point

    @t = [0,[@t,1].min].max

    @pt = [@t*(@lon2-@lon1)+@lon1, @t*(@lat2-@lat1)+@lat1]

    # distance and direction to that point

    # TODO: again, using great circle methods here is probably
    # excessive, especially since I assumed planar geometry above

    @dist = gcdist(@pt[0], @pt[1], $USER.LON, $USER.LAT)

    @dir = gcdir($USER.LON, $USER.LAT, @pt[0], @pt[1])

  end

  # the fly command to display this segment in a given tile

  def fly(t,width,height)

    pt1 = t.xy(lon1,lat1,width,height)
    pt2 = t.xy(lon2,lat2,width,height)
    "line #{pt1[0]},#{pt1[1]},#{pt2[0]},#{pt2[1]},0,0,255"

  end

  # return the point 'x' way along this segment [lon,lat] (x=0 is
  # start of segment, x=1 is end of segment)

  def partway(x) [@lon1+x*(@lon2-@lon1), @lat1+x*(@lat2-@lat1)] end

end

# functions a user can call from the game prompt

# TODO: this is an ugly class because it changes global variables

# TODO: this should probably be a static class (does ruby support that?)

class UserFunctions

  def parse(s)

    # handle multiple commands using recursion

    if s.match(';') then s.split(";").each{|i| parse(i)}; return end


    # parse user input: "foo bar x" tries to call foo_bar_x() first, then
    # foo_bar(x), then foo(bar,x)

    words = s.split(" ")

    words.each_index{|i|
      com = words[0..words.length-i-1].join("_")
      if (respond_to?(com)) then
	return method(com).call(*words[words.length-i..words.length])
      end
    }
    
    # if no methods found, return error

    return "Command not understood: #{s}"

  end

  # TODO: the nils here are to avoid returning unwanted information to user

  # NOTE: the semicolons after the nils may be unnecessary

  # travel north x meters

  def n(x=$USER.SPEED) $USER.LAT+=x/6372795/PI*180; nil; end
  
  # travel east x meters (note that cosine adjusts for latitude)

  def e(x=$USER.SPEED) $USER.LON+=x/6372795/PI*180/cosd($USER.LAT); nil; end

  # TODO: I may have screwed these up somehow -- west now goes east?

  # the remaining cardinal directions can be derived from north and east

  def s(x=$USER.SPEED) n(-1*x) end
  def w(x=$USER.SPEED) e(-1*x) end
  def ne(x=$USER.SPEED) n(x/sqrt(2));e(x/sqrt(2)) end
  def se(x=$USER.SPEED) s(x/sqrt(2));e(x/sqrt(2)) end
  def sw(x=$USER.SPEED) s(x/sqrt(2));w(x/sqrt(2)) end
  def nw(x=$USER.SPEED) n(x/sqrt(2));w(x/sqrt(2)) end

  # change the user's speed (movement per turn)

  def speed(x) $USER.SPEED=x; nil; end
  
  # teleport the user to requested coordinates

  def teleport(x,y) $USER.LON=x; $USER.LAT=y; nil; end

  # detailed information about a way or a node

  def examine_way(n) $ways[n.to_i].to_s end

  def examine_node(n) $nodes[n.to_i].to_s end

  # go to a node or way (closest point on way)

  def go_way(n) $USER.LON,$USER.LAT = $ways[n.to_i].pt; nil; end

  def go_node(n) $USER.LON,$USER.LAT = $nodes[n.to_i].lon,$nodes[n.to_i].lat; nil; end

  # connect to a way so future movement is along the way
  # TODO: this probably not super useful at the moment

  def attach_way(n)

    $USER.ATTACH = n # record what way we're on
    $USER.SEGMENT = $ways[n.to_i].order + $ways[n.to_i].t # where on way
    go_way(n) # and actually move there

  end

  def unattach() $USER.ATTACH=0; nil; end

  # travel on attached way

  def u(x=$USER.SPEED)

    if (!$USER.ATTACH || 0==$USER.ATTACH) then return "Not attached to a way" end

    # determine new segment

    $USER.SEGMENT = $ways[$USER.ATTACH.to_i].travel($USER.SEGMENT,x)

    $USER.LON,$USER.LAT = $ways[$USER.ATTACH.to_i].segpoint($USER.SEGMENT)
    nil

  end

  # information about the user itself

  def info() $USER.inspect end

  # moving "down" along the way is just moving the opposite direction

  def d(x=$USER.SPEED) u(-1*x) end

  # Set ANY variable on user object (for undocumented/etc variables)

  def set(var,val) $USER.send("#{var}=#{val}"); nil; end
  
  # the help function

  def h()
    # TODO: implement unimplemented functions below
"n,s,e,w,ne,se,sw,ne - move in cardinal direction
u,d - move along attached way (u = move in direction of way)
go ((way|node) x|name) - go to node x/nearest point on way x
attach (way x|name) - attach to way x; future moves are u,d along x
unattach - unattach and move normally again
teleport x y - teleport to longitude/latitude x y
speed x - change speed to x meters/turn
display [z] - display slippy map of current tile (z = zoom level, default 16)
fly - display fly map of current tile (always zoom 16)
# odom - start/stop odometer (measure distance along path, not straight line)
hidden [0|1] - if 1, show anonymous nodes and ways
all [0|1] - if 1, show all nodes/ways, don't limit to 20 (default) of each
info - more detailed info about your current location, speed, attached-way, etc
examine ((way|node) x|name) - show all information about way/node
# clear - clear the cache of known nodes/ways
set var val - set var to val in User object (can replace functions above)
; - use to separate multiple commands
q - quit
# = not yet implemented
"
  end

  # create the slippy tile image for where the user is, and use fly to
  # superimpose "YOU ARE HERE" dot; for docker, just return file
  # location

  def display(n=$ZOOM_LEVEL)

    # get the slippy tile for this position + superimpose user position

    t = Tile.tile(n,$USER.LON,$USER.LAT)

    debug("GIF IS: #{t.gif}");

    # user position for superimposition
    x,y = t.xy($USER.LON,$USER.LAT,256,256)

    # TODO: using a constant file name here is probably bad

    File.new("/tmp/osmbrowse.fly","w").spew("existing #{t.gif}\nfcircle #{x},#{y},5,255,0,0\nstring 0,0,0,#{x},#{y},tiny,YOU ARE HERE")
    system("fly -i /tmp/osmbrowse.fly -o /tmp/osmbrowse.gif")

    return "See /tmp/osmbrowse.gif; docker version can not run image displayer itself"

    # TODO: change to feh or display?
    # system("xv /tmp/osmbrowse.gif &"); nil;

  end

  # use fly to create an image and tell where it is (docker limitation)

  def fly()

    t = Tile.tile($ZOOM_LEVEL,$USER.LON,$USER.LAT)

    # user position for superimposition
    x,y = t.xy($USER.LON,$USER.LAT,$WIDTH,$HEIGHT)

    # use the way's own fly command to put the ways into image

    f = File.new("/tmp/osmbrowse.fly","w")
    f.write("new\nsize #{$WIDTH},#{$HEIGHT}\nsetpixel 0,0,0,0,0\n")
    f.write($ways.collect{|i,j| j.fly(t,$WIDTH,$HEIGHT)}.join("\n"))
    
    # TODO: SHOW_NODES is undocumented
    # have the nodes return commands to print themselves

    if ($USER.SHOW_NODES > 0) then
      f.write($nodes.collect{|i,j| j.fly(t,$WIDTH,$HEIGHT)}.join("\n"))
    end

    # add superimposition dot

    f.write("\nfcircle #{x},#{y},5,255,0,0\nstring 255,255,255,#{x},#{y},tiny,YOU ARE HERE")

    f.close
    system("fly -q -i /tmp/osmbrowse.fly -o /tmp/osmbrowse.gif")
    
    return "See /tmp/osmbrowse.gif for image; docker version cannot display image directly"

    # system("xv /tmp/osmbrowse.gif &"); nil;

  end

  def q() exit end

  # find a way or node by name -- returns "way (x)" or "node (x)"

  # TODO: this is fairly ugly/hacky-- always searches nodes first, for example

  # TODO: if name is a pure number, we should return it; currently,
  # you can't examine/go to ways or nodes by number

  # TODO: this is a helper function called by `examine`; if we decide
  # the user can't call it directly (currently not documented), it
  # shouldn't be in the Userfunctions object

  def find_node_way(name, ways_only=0)

    # search for nodes unless ways_only is set

    if (0 == ways_only) then

      # find the closest node where the node name regex matches the given name

      for i,j in $nodes.sort_by{|i,n| n.dist}

	if j.tags['name'].match(Regexp.new("^#{name}",true)) then
	  return "node #{i}"
	end

      end

    end

    for i,j in $ways.sort_by{|i,w| w.dist}

      if j.tags['name'].match(Regexp.new("^#{name}",true)) then
	return "way #{i}"
      end

    end

    # no way or node regex matching parameter name

    return false

  end

  # if examine/go/attach given w/o node/way number, use find_node_way

  def examine(x)

    res = find_node_way(x)
    if res then return parse("examine #{res}") else return "#{x} not found" end

  end
    
  def go(x)

    res = find_node_way(x)
    if res then return parse("go #{res}") else return "#{x} not found" end

  end

  # for attach, we only care about ways

  def attach(x)

    res = find_node_way(x,1)
    if res then return parse("attach #{res}") else return "#{x} not found" end

  end

  # simple settings

  def hidden(x=1) $USER.HIDDEN=x; nil; end
  def all(x=1) $USER.SHOW_ALL=x; nil; end

  # bunch of aliases

  alias north n
  alias south s
  alias east e
  alias west w
  alias northeast ne
  alias northwest nw
  alias southeast se
  alias southwest sw
  alias help h
  alias quit q

end

# a slippy tile with standard use of x, y, and z as parameters

class Tile

  include Util
  
  # When initializing, also determine bbox

  def initialize(s)
    setfields(s)
    @minlon = 360/2**@z*@x-180
    @maxlon = @minlon+360/2**@z
    @minlat = -atan(sinh(2*PI*(@y+1)/2**@z-PI))*180/PI
    @maxlat = -atan(sinh(2*PI*@y/2**@z-PI))*180/PI
  end

  # find the level-z tile containing a given latitude/longitude

  def self.tile(z,lon,lat)
    x = ((lon+180)/360*2**z).floor
    y = (2**z*(log(tand(lat)+1/cosd(lat))/2/-PI+0.5)).floor
    return Tile.new("x=#{x}&y=#{y}&z=#{z}")
  end

  # the tile at the next lower zoom level containing this one, false if z=0

  def parent()
    z==0?false:Tile.new("x=#{@x.div(2)}&y=#{@y.div(2)}&z=#{@z-1}")
  end

  # all parents of this tile right up to world tile (0/0/0)
  # TODO: there has to be a better way to do below using iterators

  def parents()
    t = self
    res = Array.new()
    while t do
      res.push(t)
      t = t.parent
    end
    res
  end

  # download the image file for this tile

  # TODO: don't cache images forever like I am doing now

  def png()

    filename = "#{$MYDIR}/#{@z}-#{@x}-#{@y}.png"

    if File.exist?(filename) then return filename end

    # if the file doesn't exist, use curl to pull the image

    url = "https://tile.openstreetmap.org/#{@z}/#{@x}/#{@y}.png"

    debug("Downloading: #{url}")

    # TODO: silence curl
    system("curl -o #{filename} #{url}")
    return filename

  end

  # get the data for this tile and return file name w/ that data

  # TODO: check for parent tiles?

  # TODO: the whole mess with parent tiles here is in case the user is
  # "in the middle of nowhere"-- we make an effort to show them the
  # nearest "thing" even if it's not nearby

  def data()

    # TODO: age/expire data files?

    # check to see if I already have a parent tile (including myself)

    # TODO: this should only occur in cases where the tile itself has
    # no features

    for i in self.parents.reverse do
      filename = "#{$MYDIR}/#{i.z}-#{i.x}-#{i.y}.dat"
      if File.exist?(filename) then return filename end
    end

    # get the data for this tile, since I don't already have it

    # TODO: use Overpass API instead

    url = "https://www.openstreetmap.org/api/0.6/map?bbox=#{minlon},#{minlat},#{maxlon},#{maxlat}"

    # TODO: silence curl

    debug("Downloading: #{url}");

    system("curl -o #{filename} #{url}")

    # three possibilities: error, no data (bbox too big), and OK

    # TODO: really should use Exceptions/try/catch here

    # the -1 return below means we requested too big a bbox -- it's
    # assumed we never do this right from the start and that this is a
    # recursive call and that the calling instance of data() will
    # handle a return value of -1

    if (File.size(filename) < 2) then 
      File.delete(filename)
      return -1 
    end

    # if we get too little data, try the parent tile, but if we get
    # back -1, settle for what we already have

    # TODO: decide what "too little data" means (currently < 1000 bytes)

    if (File.size(filename) < 1000) then
      return -1==parent.data()?filename:parent.data()
    end
    
    # we got enough data, so return filename

    return filename

  end

  # get tiles within Manhattan distance n of this tile

  def neighbors(n=1) 

    # TODO: could probably use iterators and collect here to prune code

    res = Array.new()

    for x in (@x-n).to_i..(@x+n).to_i
      for y in (@y-n).to_i..(@y+n).to_i

        # nearby tiles to +-180 degrees longitude may "wraparound"
	x = x%2**@z

        # if tile is already at latitude boundary, don't return the
        # non-existent tiles further north/south of it

	if (y>=0 && y<2**@z) then 
	  res.push(Tile.new("x=#{x}&y=#{y}&z=#{@z}")) 
	end

      end

    end

    return res

  end

  # the x and y coordinates of a given latitude/longitude in this
  # tile, given width and height of image; note that slippy tiles are
  # always 256x256 (except high res ones are 512x512?), but this
  # allows us to draw this tile using a different program, not using
  # existing tile images


  def xy(lon,lat,width,height)

    # TODO: assuming linearity-- incorrect, but close enough for small tiles

    # TODO: broken for big tiles (levels 4 + less are really bad)

    [((lon-@minlon)/(@maxlon-@minlon)*width).round,
      ((@maxlat-lat)/(@maxlat-@minlat)*height).round]
  end

  # ugly hack because fly needs GIF files, not PNG files

  def gif()
    gif = png.gsub('.png','.gif')
    system("convert #{png} #{gif}")
    return gif
  end

end

# great circle distance (in meters) between two points
# http://en.wikipedia.org/w/index.php?title=Great-circle_distance&oldid=176992051

def gcdist(lon1,lat1,lon2,lat2)

  # TODO: ugly hack below because arg can trivially exceed 1 sometimes

  arg = sind(lat1)*sind(lat2)+cosd(lat1)*cosd(lat2)*cosd(lon1-lon2)

  6372795*acos([arg,1].min)

end

# great circle direction between two points
# http://mathforum.org/library/drmath/view/55417.html

def gcdir(lon1,lat1,lon2,lat2)

  num = sind(lon2-lon1)*cosd(lat2)

  den = cosd(lat1)*sind(lat2)-sind(lat1)*cosd(lat2)*cosd(lon2-lon1)

  atan2(den,num)/DEGREE

end


# NOTE: data2 is a very hacky way of getting OSM XML data; as the name
# implies, there was a data() function that did it corretly, but was
# too slow

# TODO: as part of refactoring, perhaps look at data() again

# returns the (possibly cached) nodes and ways (hashes) for a given tile

def data2(t)

  nodes_cache_file = "#{$MYDIR}/#{t.z}-#{t.x}-#{t.y}-nodes.msh"
  ways_cache_file = "#{$MYDIR}/#{t.z}-#{t.x}-#{t.y}-ways.msh"

  # NOTE: both files must exist-- can't really marshal from just one

  if (File.exist?(nodes_cache_file) && File.exist?(ways_cache_file)) then
    nodes = Marshal.restore(File.new(nodes_cache_file).read)
    ways = Marshal.restore(File.new(ways_cache_file).read)
    return [nodes,ways]
  end

  cur = [] 

  ways = Hash.new()
  nodes = Hash.new()

  File.new(t.data).readlines.each{|i|

    # NOTE: for this to work LC_ALL must be set to not 'C'

    i.gsub!(/[\u0080-\u00ff]/, '')

    i =~ /<(node|way|nd|tag) (.*?)\/?>/
    
    # ignore lines not matching any string above
    # TODO: maybe report bad lines

    if ($~.nil?) then next end

    # the tag type

    type = $~[1]

    # cleanup line to create init string/hash
    # note that we can't set the `id` of a Ruby object, so we use `oid` instead

    str = $~[2].gsub('" ','&').gsub("id=","oid=").gsub('="','=').gsub('"','').gsub("&quot;","'")

    h = Hash.new.setfields(str)

    if (type == "node") then

      # creates a new node and places it in the nodes psuedo-array

      # TODO: make it clearer here that cur.oid can be very large, and
      # that nodes[] does not create unnecessary elements

      cur = Node.new(h)
      nodes[cur.oid.to_i] = cur

    elsif (type == "way") then

      # create a new way and add it to the ways array

      cur = Way.new(h)
      ways[cur.oid.to_i] = cur

    elsif (type == "nd") then

      # add node to current way

      cur.add(nodes[h["ref"].to_i])

    elsif (type =="tag") 

      # add tag to current object

      cur.add_tag(h["k"],h["v"])

    end

  }

  # dump serialized versions of nodes/ways to cachefile

  # TODO: is dumping nodes that are part of ways redundant? (we might
  # end up w/ redundant nodes, which is ugly)

  # TODO: does this really give us any speed improvement?

  File.new(nodes_cache_file,"w").spew(Marshal.dump(nodes))
  File.new(ways_cache_file,"w").spew(Marshal.dump(ways))

  return [nodes,ways]

end

# User is a trivial object that gets most/all functionality from Util

class User
  include Util
end

# default settings for user (unless marshalled object exists)

# NOTE: SHOW_NODES = show on fly map; named nodes are ALWAYS shown in
# text interface

# TODO: MAX_NODES/MAX_WAYS are undocumented vars

$USER = User.new("LON=0.152478&LAT=52.235914&SPEED=50&SHOW_NODES=1&MAX_NODES=15&MAX_WAYS=15&HIDDEN=0&SHOW_ALL=0")

# TODO: make these user controllable

$WIDTH=1600
$HEIGHT = 900

# file where user information is stored between runs

$MARSHAL = "#{$MYDIR}/User.msh"

# if user information file exists, load it (thus overriding defaults above)

if File.exist?($MARSHAL) then 
  $USER=Marshal.restore(File.new($MARSHAL).read)
end

# TODO: silly to instantiate "static" object, but I'm lazy
# TODO: should probably fix this

u = UserFunctions.new()

# TODO: should nodes/ways NOT be cleaned out when you move?

# TODO: use Tk to display "fly" maps instead of Unix 'xv' cmd?

# TODO: nodes/ways should have a name() method (not just x.tags['name'])?

# main body of program

while 1 do

  # init nodes/ways each time

  # TODO: consider memory cacheing (ie, not overwriting these at each
  # iteration), but it's tolerably fast as is

  $nodes = Hash.new()
  $ways = Hash.new()

  # load data for current tile + immediate neighbors

  tile = Tile.tile($ZOOM_LEVEL,$USER.LON,$USER.LAT)
  tile.neighbors.each{|i|
    n,w = data2(i)
    $nodes.merge!(n)
    $ways.merge!(w)
  }

  # update relative-to-user info for all nodes and tiles

  $nodes.each{|i,n| n.relative_info()}
  $ways.each{|i,w| w.relative_info()}

  # TODO: could intermix nodes and ways, instead of nodes first, then ways

  # sort nodes/ways by distance from $USER + remove anonymous nodes/ways
  # unless $USER.HIDDEN is set

  # currently nodes and ways display 'name' tag or nothing if there is
  # no 'name' tag

  $show_nodes = $nodes.sort_by{|i,n| n.dist}.select{|i,n| $USER.HIDDEN>0||n.tags['name']}

  $show_ways = $ways.sort_by{|i,w| w.dist}.select{|i,w| $USER.HIDDEN>0||w.tags['name']}

  # TODO: there's probably a way to combine this w/ code above

  # actually print the nodes, then the way, separated by a newline

  $show_nodes[0..(($USER.SHOW_ALL>0)?$nodes.length-1:$USER.MAX_NODES).to_i].each{|i,n| print n.short()}

  print "\n"

  $show_ways[0..(($USER.SHOW_ALL>0)?$ways.length-1:$USER.MAX_WAYS).to_i].each{|i,w| print w.short()}

  # print the command prompt
  # TODO: don't print newline after prompt (but how?)

  print "[#{$USER.LON},#{$USER.LAT}] ('h' for help) > "

  # read the command, ignoring the newline

  command = readline.strip

  # if command returns something, print it and wait for user to hit return

  res = u.parse(command)

  # TODO: original code required user to hit <RETURN> before
  # continuing to avoid data scrolling off screen; however that is
  # REALLY annoying, so I'm turning it off for now

  if res then print "#{res}" end

#    print "#{res}\nHit <RETURN> to continue"
    # TODO: if user types command instead of just <RETURN>, it's ignored (bad!)
#    readline
#  end

  # TODO: for now, saving user position every turn in case program
  # crashes (or even if user quite voluntarily)-- find better solution
  # to this perhaps creating a 'save' command

  File.new($MARSHAL,"w").spew(Marshal.dump($USER))

end

# TODO: add command cacheing for all commands
