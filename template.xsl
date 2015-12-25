<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="html" encoding="UTF-8" indent="yes" omit-xml-declaration="yes" />

<!--
  <xsl:param name="rows" select="2" />
  <xsl:param name="cols" select="4" />
  <xsl:variable name="pageSize" select="$rows * $cols" />
  <xsl:include href="spell_template.xsl"/>
  <xsl:include href="monster_template.xsl"/>
  <xsl:include href="item_template.xsl"/>
-->

  <xsl:template match="cards">
    <xsl:text disable-output-escaping='yes'>&lt;!DOCTYPE html&gt;</xsl:text>

    <html>
      <head>
        <link rel="stylesheet" type="text/css" href="cards.css"/>
      </head>
      <body class="{$pageFormat}">
        <div class="container {$pageFormat}">
          <xsl:apply-templates select="spells/spell[position() mod $pageSize = 1]" />
          <xsl:apply-templates select="monsters/monster[position() mod $pageSize = 1]" />
          <xsl:apply-templates select="items/item[position() mod $pageSize = 1]" />
          <xsl:apply-templates select="references/reference[position() mod $pageSize = 1]" />
        </div>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="spell|monster|item|reference">
    <!-- fronts -->
    <div class="page">
      <xsl:call-template name="printRows">
        <xsl:with-param name="mode" select="'front'"/>
        <xsl:with-param name="order" select="'ascending'" />
        <xsl:with-param name="type" select="name()" />
      </xsl:call-template>
    </div>
    <!-- backs -->
    <div class="page">
      <xsl:call-template name="printRows">
        <xsl:with-param name="mode" select="'back'"/>
        <xsl:with-param name="order" select="'descending'" />
      </xsl:call-template>
    </div>
  </xsl:template>

  <xsl:template name="printRows">
    <xsl:param name="mode" />
    <xsl:param name="order" />

    <xsl:variable name="thePage"
        select=". | following-sibling::*[position() &lt; $pageSize]" />
    <!-- split into rows -->
    <xsl:for-each select="$thePage[position() mod $cols = 1]">
      <div class="row">
        <xsl:variable name="elementName" select="name(.)"/>
        <xsl:variable name="theRow"
            select=". | following-sibling::node()[name() = $elementName][position() &lt; $cols]" />

        <xsl:if test="$order = 'descending'">
          <!--
          special case for a short reverse row (i.e. the last row of the last page) - we need
          to left-pad this row with empty columns to get the right positioning
          -->
          <xsl:call-template name="emptyDivs">
            <xsl:with-param name="num" select="$cols - count($theRow)" />
          </xsl:call-template>
        </xsl:if>

        <!-- and process each row in appropriate order -->
        <xsl:choose>
          <xsl:when test="$mode = 'front'">
            <xsl:apply-templates select="$theRow" mode="front">
              <xsl:sort select="position()" order="{$order}" data-type="number" />
            </xsl:apply-templates>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="$theRow" mode="back">
              <xsl:sort select="position()" order="{$order}" data-type="number" />
            </xsl:apply-templates>
          </xsl:otherwise>
        </xsl:choose>
      </div>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="emptyDivs">
    <xsl:param name="num"/>
    <xsl:if test="$num &gt; 0">
      <div class="padding back card" />
      <xsl:call-template name="emptyDivs">
        <xsl:with-param name="num" select="$num - 1" />
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template match="name">
    <div class="name"><xsl:value-of select="."/></div>
  </xsl:template>

  <xsl:template match="description | shortDescription">
    <div class="description">
      <xsl:copy-of disable-output-escaping="yes" select="*|text()" />
    </div>
  </xsl:template>

</xsl:stylesheet>
