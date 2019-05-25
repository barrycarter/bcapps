#!/bin/perl

# it turns out qgis idiotically doesn't read SLD files even though it
# writes them; this is a copy of bc-write-sld.pl that writes qml files

# attempts to write a SLD for landuse map based on sample SLDs I have found

require "/usr/local/lib/bclib.pl";

# the style name and prop used to determine value for landuse

my($style) = "landuse";

my($prop) = "GRAY_INDEX";

my(@rules);

for $i (split(/\n/, read_file("$bclib{githome}/MAPS/ESACCI-LC-Legend.csv"))) {

  my($gray, $desc, $r, $g, $b) = split(/;/, $i);

  my($str) = sprintf("#%0.2x%0.2x%0.2x", $r, $g, $b);

  my $rule = << "MARK";

        <se:Rule>
          <se:Name>$gray</se:Name>
          <se:Description>
            <se:Title>$gray</se:Title>
          </se:Description>
          <ogc:Filter xmlns:ogc="http://www.opengis.net/ogc">
            <ogc:PropertyIsEqualTo>
              <ogc:PropertyName>GRAY_INDEX</ogc:PropertyName>
              <ogc:Literal>$gray</ogc:Literal>
            </ogc:PropertyIsEqualTo>
          </ogc:Filter>
          <se:PolygonSymbolizer>
            <se:Fill>
              <se:SvgParameter name="fill">$str</se:SvgParameter>
            </se:Fill>
            <se:Stroke>
              <se:SvgParameter name="stroke">#000001</se:SvgParameter>
              <se:SvgParameter name="stroke-width">1</se:SvgParameter>
              <se:SvgParameter name="stroke-linejoin">bevel</se:SvgParameter>
            </se:Stroke>
          </se:PolygonSymbolizer>
        </se:Rule>

MARK
;

  push(@rules, $rule);

  debug("$gray, $r $g $b");
}

my $rules = join("\n", @rules);

my($start) = << "MARK";

<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:ogc="http://www.opengis.net/ogc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.1.0" xmlns:xlink="http://www.w3.org/1999/xlink" xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.1.0/StyledLayerDescriptor.xsd" xmlns:se="http://www.opengis.net/se">
  <NamedLayer>
    <se:Name>$style</se:Name>
    <UserStyle>
      <se:Name>$styles</se:Name>
      <se:FeatureTypeStyle>
MARK
;


my($end) = << "MARK";

      </se:FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>

MARK
;

print join("\n", $start, $rules, $end), "\n";

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

=cut
