#!/bin/perl

# attempts to write a SLD for landuse map based on sample SLDs I have found

require "/usr/local/lib/bclib.pl";

for $i (split(/\n/, read_file("$bclib{githome}/MAPS/ESACCI-LC-Legend.csv"))) {

  my($gray, $desc, $r, $g, $b) = split(/;/, $i);

  debug("$gray, $r $g $b");
}




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
