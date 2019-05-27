#!/bin/perl

# it turns out qgis idiotically doesn't read SLD files even though it
# writes them; this is a copy of bc-write-sld.pl that writes qml files

# attempts to write a SLD for landuse map based on sample SLDs I have found

require "/usr/local/lib/bclib.pl";

# the style name and prop used to determine value for landuse

my($style) = "landuse";

my($prop) = "GRAY_INDEX";

my($symb) = -1;

my(@syms, @cats);

for $i (split(/\n/, read_file("$bclib{githome}/MAPS/ESACCI-LC-Legend.csv"))) {

  $i=~s/(\r|\n)//g;

  # sequentially numberbing symbols
  $symb++;

  my($gray, $desc, $r, $g, $b) = split(/;/, $i);

  # skip header line
  if ($gray eq "NB_LAB") {next;}


  push(@cats, "<category render='true' symbol='$symb' value='$gray' label=''/>");

  my $symbol = << "MARK";

      <symbol alpha="1" clip_to_extent="1" type="fill" name="$symb">
        <layer pass="0" class="SimpleFill" locked="0">
          <prop k="border_width_map_unit_scale" v="0,0,0,0,0,0"/>
          <prop k="color" v="$r,$g,$b,255"/>
          <prop k="joinstyle" v="bevel"/>
          <prop k="offset" v="0,0"/>
          <prop k="offset_map_unit_scale" v="0,0,0,0,0,0"/>
          <prop k="offset_unit" v="MM"/>
          <prop k="outline_color" v="0,0,0,255"/>
          <prop k="outline_style" v="solid"/>
          <prop k="outline_width" v="0.26"/>
          <prop k="outline_width_unit" v="MM"/>
          <prop k="style" v="solid"/>
        </layer>
      </symbol>
MARK
;

  push(@syms, $symbol);
}

my $syms = join("\n", @syms);
my $cats = join("\n", @cats);


my($start) = << "MARK";

<!DOCTYPE qgis PUBLIC 'http://mrcc.com/qgis.dtd' 'SYSTEM'>
<qgis version="2.14.9-Essen" minimumScale="0" maximumScale="1e+08" simplifyDrawingHints="1" minLabelScale="0" maxLabelScale="1e+08" simplifyDrawingTol="1" simplifyMaxScale="1" hasScaleBasedVisibilityFlag="0" simplifyLocal="1" scaleBasedLabelVisibilityFlag="0">

<renderer-v2 attr="$prop" forceraster="0" symbollevels="0" type="categorizedSymbol" enableorderby="0">

MARK
;


my($end) = << "MARK";

  </renderer-v2>
</qgis>

MARK
;

print join("\n", $start,"<categories>", $cats, "</categories>", 
	   "<symbols>", $syms, "</symbols>", $end), "\n";

=item comments

Rule sample:

        <se:Rule>
          <se:Name>1</se:Name>
          <se:Description>
            <se:Title>1</se:Title>
          </se:Description>
          <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>map_color8</ogc:PropertyName>
              <ogc:Literal>1</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:Filter>
          <se:PolygonSymbolizer>
            <se:Fill>
              <se:SvgParameter name="fill">#9e0142</se:SvgParameter>
            </se:Fill>
            <se:Stroke>
              <se:SvgParameter name="stroke">#000001</se:SvgParameter>
              <se:SvgParameter name="stroke-width">1</se:SvgParameter>
              <se:SvgParameter name="stroke-linejoin">bevel</se:SvgParameter>
            </se:Stroke>
          </se:PolygonSymbolizer>
        </se:Rule>

The start part:

<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.1.0/StyledLayerDescriptor.xsd" xmlns:se="http://www.opengis.net/se">
  <NamedLayer>
    <se:Name>ne_10m_time_zones</se:Name>
    <UserStyle>
      <se:Name>ne_10m_time_zones</se:Name>
      <se:FeatureTypeStyle>

The end part:

      </se:FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>

For qml, ignoring "<edittypes>", sense I don't need them



=cut
