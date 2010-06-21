<?xml version='1.0'?> 
<xsl:stylesheet  
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:fo="http://www.w3.org/1999/XSL/Format"
	xmlns:d="http://docbook.org/ns/docbook"
	xmlns:exsl="http://exslt.org/common"
    extension-element-prefixes="exsl"
    exclude-result-prefixes="exsl d"
    version="1.0"> 


<xsl:import href="deps.xsl"/>
<xsl:output method="xml" indent="no"/>
<xsl:param name="use.extensions" select="1"/>
<xsl:param name="fop1.extensions" select="1"/>
<xsl:param name="draft.mode">no</xsl:param>
<xsl:param name="hyphenate">true</xsl:param>
<xsl:param name="l10n.gentext.default.language">DE</xsl:param>
<xsl:param name="ulink.footnotes" select="1"/>
<xsl:param name="ulink.show" select="1"/>
<xsl:param name="table.footnote.number.format" select="'1'"/>
<xsl:param name="table.footnote.number.symbols" select="''"/>
<xsl:param name="highlight.source" select="1"/>
<xsl:param name="line-height" select="1.3"/>
<xsl:param name="qandadiv.autolabel" select="0"/>
<xsl:param name="keep.relative.image.uris" select="1"/>
<xsl:param name="paper.type" select="'A4'"/>

<!-- Format Variable Lists as Blocks (prevents horizontal overflow). -->
<xsl:param name="variablelist.as.blocks">1</xsl:param>

<xsl:param name="default.image.width" select="'440'"/>
<xsl:param name="body.font.master">9</xsl:param>

<xsl:param name="title.font.family">
	<xsl:text>MetaPlusBold</xsl:text>
</xsl:param>

<xsl:param name="body.font.family">
	<xsl:text>Georgia</xsl:text>
</xsl:param>

<xsl:param name="monospace.font.family">
	<xsl:text>DejaVuSansMono</xsl:text>
</xsl:param>

<xsl:param name="sans.font.family">
	<xsl:text>DejaVuSans</xsl:text>
</xsl:param>

<!-- No intendation of Titles -->
<xsl:param name="title.margin.left">0pc</xsl:param>
<xsl:param name="title.color">#000033</xsl:param>

<xsl:attribute-set name="formal.title.properties" use-attribute-sets="normal.para.spacing">
	<xsl:attribute name="color"><xsl:value-of select="$title.color"/></xsl:attribute>
	<xsl:attribute name="background-color">white</xsl:attribute>
	<xsl:attribute name="font-weight">bold</xsl:attribute>
	<xsl:attribute name="font-size">
		<xsl:value-of select="$body.font.master * 1.2"/>
		<xsl:text>pt</xsl:text>
	</xsl:attribute>
	<xsl:attribute name="hyphenate">false</xsl:attribute>
	<xsl:attribute name="space-before.optimum"><xsl:value-of select="concat($body.font.master, 'pt')"/></xsl:attribute>
	<xsl:attribute name="space-before.minimum"><xsl:value-of select="concat($body.font.master, 'pt')"/></xsl:attribute>
	<xsl:attribute name="space-before.maximum"><xsl:value-of select="concat($body.font.master, 'pt')"/></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="qanda.title.properties">
  <xsl:attribute name="font-family">
    <xsl:value-of select="$title.font.family"/>
  </xsl:attribute>
  <xsl:attribute name="font-weight">bold</xsl:attribute>
  <!-- font size is calculated dynamically by qanda.heading template -->
  <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0.8em</xsl:attribute>
  <xsl:attribute name="space-before.optimum">1.0em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">1.2em</xsl:attribute>
  <xsl:attribute name="color"><xsl:value-of select="$title.color"/></xsl:attribute>
</xsl:attribute-set>

<!-- Admonitions -->
<xsl:param name="admon.graphics" select="1"/>
<xsl:param name="admon.graphics.extension">.svg</xsl:param>
<!--<xsl:param  name="admon.graphics.path">docbook-xsl-ns-1.75.2/images/</xsl:param>-->
<xsl:attribute-set name="admonition.title.properties">
	<xsl:attribute name="font-size">13pt</xsl:attribute>
	<xsl:attribute name="color"><xsl:text>#000033</xsl:text></xsl:attribute>
	<xsl:attribute name="font-weight">bold</xsl:attribute>
	<xsl:attribute name="hyphenate">true</xsl:attribute>
	<xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="graphical.admonition.properties">
	<xsl:attribute name="color"><xsl:text>#000033</xsl:text></xsl:attribute>
	<xsl:attribute name="background-color">
	  <xsl:choose>
		<xsl:when test="local-name(.)='note'">
			<xsl:text>#C1FDF4</xsl:text>
		</xsl:when>
		<xsl:when test="local-name(.)='important'">
			<xsl:text>#FEC023</xsl:text>
		</xsl:when>
		<xsl:when test="local-name(.)='warning'">
			<xsl:text>#D45450</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>#DEFF99</xsl:text>
		</xsl:otherwise>
	  </xsl:choose>
	</xsl:attribute>
	<xsl:attribute name="space-before.optimum">1em</xsl:attribute>
	<xsl:attribute name="space-before.minimum">0.8em</xsl:attribute>
	<xsl:attribute name="space-before.maximum">1.2em</xsl:attribute>
	<xsl:attribute name="space-after.optimum">1em</xsl:attribute>
	<xsl:attribute name="space-after.minimum">0.8em</xsl:attribute>
	<xsl:attribute name="space-after.maximum">1em</xsl:attribute>
	<xsl:attribute name="padding-bottom">12pt</xsl:attribute>
	<xsl:attribute name="padding-top">12pt</xsl:attribute>
	<xsl:attribute name="padding-right">12pt</xsl:attribute>
	<xsl:attribute name="padding-left">12pt</xsl:attribute>
	<xsl:attribute name="margin-left">
		<xsl:value-of select="$title.margin.left"/>
	</xsl:attribute>
</xsl:attribute-set>

<!-- http://www.sagehill.net/docbookxsl/PrintOutput.html#DoubleSided -->
<xsl:param name="double.sided" select="1"/>

<!--  Section, Chapter Numbering -->
<!-- http://www.sagehill.net/docbookxsl/SectionNumbering.html -->
<xsl:param name="toc.section.depth">3</xsl:param>
<xsl:param name="appendix.autolabel" select="'A'"/>
<xsl:param name="chapter.autolabel" select="1"/>
<xsl:param name="part.autolabel" select="'I'"/>
<xsl:param name="reference.autolabel" select="'I'"/>
<xsl:param name="section.autolabel" select="1"/>
<xsl:param name="section.label.includes.component.label" select="1"/>

<xsl:param name="hyphenate.verbatim" select="0"></xsl:param>

<xsl:attribute-set name="xref.properties">
  <xsl:attribute name="font-style">italic</xsl:attribute>
  <xsl:attribute name="color">
	<xsl:choose>
		<xsl:when test="ancestor::note or ancestor::important or ancestor::warning">
			<xsl:text>#aee6ff</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>#0066cc</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="monospace.properties">
	<!--xsl:attribute name="font-size">9pt</xsl:attribute-->
	<xsl:attribute name="font-family">
		<xsl:value-of select="$monospace.font.family"/>
	</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="monospace.verbatim.properties" 
                   use-attribute-sets="verbatim.properties monospace.properties">
  <xsl:attribute name="text-align">start</xsl:attribute>
  <xsl:attribute name="wrap-option">wrap</xsl:attribute>
  <xsl:attribute name="hyphenation-character">-</xsl:attribute>
</xsl:attribute-set>



<xsl:param name="shade.verbatim" select="1"/>
<xsl:attribute-set name="shade.verbatim.style">
  <xsl:attribute name="wrap-option">wrap</xsl:attribute>
  <!--<xsl:attribute name="hyphenation-character">\</xsl:attribute>-->
  <xsl:attribute name="background-color">
	<xsl:choose>
		<xsl:when test="ancestor::note or ancestor::caution or ancestor::important or ancestor::warning or ancestor::tip">
			<xsl:text>#333333</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>#FBFEDF</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:attribute>
  <xsl:attribute name="color">
	<xsl:choose>
		<xsl:when test="ancestor::note or ancestor::caution or ancestor::important or ancestor::warning or ancestor::tip">
			<xsl:text>#0066cc</xsl:text>
		</xsl:when>
		<xsl:otherwise>
			<xsl:text>black</xsl:text>
		</xsl:otherwise>
	</xsl:choose>
  </xsl:attribute>
	<xsl:attribute name="padding-left">12pt</xsl:attribute>
	<xsl:attribute name="padding-right">12pt</xsl:attribute>
	<xsl:attribute name="padding-top">6pt</xsl:attribute>
	<xsl:attribute name="padding-bottom">6pt</xsl:attribute>
	<xsl:attribute name="margin-left">
		<xsl:value-of select="$title.margin.left"/>
	</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="verbatim.properties">
  <xsl:attribute name="space-before.minimum">0.8em</xsl:attribute>
  <xsl:attribute name="space-before.optimum">1em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">1.2em</xsl:attribute>
  <xsl:attribute name="space-after.minimum">0.8em</xsl:attribute>
  <xsl:attribute name="space-after.optimum">1em</xsl:attribute>
  <xsl:attribute name="space-after.maximum">1.2em</xsl:attribute>
  <xsl:attribute name="hyphenate">true</xsl:attribute>
  <xsl:attribute name="wrap-option">wrap</xsl:attribute>
  <xsl:attribute name="white-space-collapse">false</xsl:attribute>
  <xsl:attribute name="white-space-treatment">preserve</xsl:attribute>
  <xsl:attribute name="linefeed-treatment">preserve</xsl:attribute>
  <xsl:attribute name="text-align">start</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="toc.line.properties">
  <xsl:attribute name="text-align-last">justify</xsl:attribute>
  <xsl:attribute name="text-align">start</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="toc.line.properties">
  <xsl:attribute name="text-align-last">justify</xsl:attribute>
  <xsl:attribute name="text-align">start</xsl:attribute>
</xsl:attribute-set>

<!-- The horrible list spacing problems, this is much better. -->
<xsl:attribute-set name="list.block.spacing">
	<xsl:attribute name="space-before.optimum">0.1pt</xsl:attribute>
	<xsl:attribute name="space-before.minimum">0.1pt</xsl:attribute>
	<xsl:attribute name="space-before.maximum">0.1pt</xsl:attribute>
	<xsl:attribute name="space-after.optimum">1em</xsl:attribute>
	<xsl:attribute name="space-after.minimum">1em</xsl:attribute>
	<xsl:attribute name="space-after.maximum">1em</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="list.item.spacing">
  <xsl:attribute name="space-before.optimum">0.1em</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0.1em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">0.1em</xsl:attribute>
	<xsl:attribute name="space-after.optimum">1em</xsl:attribute>
	<xsl:attribute name="space-after.minimum">1em</xsl:attribute>
	<xsl:attribute name="space-after.maximum">1em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="fat.list.item.spacing" use-attribute-sets="list.item.spacing">
	<xsl:attribute name="space-after.optimum">1em</xsl:attribute>
	<xsl:attribute name="space-after.minimum">1em</xsl:attribute>
	<xsl:attribute name="space-after.maximum">1em</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="dash.list.item.spacing" use-attribute-sets="list.item.spacing">
 <xsl:attribute name="padding-top">5pt</xsl:attribute>
 <xsl:attribute name="space-before.optimum">0.5em</xsl:attribute>
  <xsl:attribute name="space-before.minimum">0.5em</xsl:attribute>
  <xsl:attribute name="space-before.maximum">0.5em</xsl:attribute>
	<xsl:attribute name="border-top-width">0.5pt</xsl:attribute>
	<xsl:attribute name="border-top-style">dashed</xsl:attribute>
	<xsl:attribute name="border-top-color">black</xsl:attribute>
</xsl:attribute-set>

<xsl:template match="listitem/*[1][local-name()='para' or 
                                   local-name()='simpara' or 
                                   local-name()='formalpara']
                     |glossdef/*[1][local-name()='para' or 
                                   local-name()='simpara' or 
                                   local-name()='formalpara']
                     |step/*[1][local-name()='para' or 
                                   local-name()='simpara' or 
                                   local-name()='formalpara']
                     |callout/*[1][local-name()='para' or 
                                   local-name()='simpara' or 
                                   local-name()='formalpara']"
              priority="2">
  <fo:block xsl:use-attribute-sets="list.item.spacing">
    <xsl:call-template name="anchor"/>
    <xsl:apply-templates/>
  </fo:block>
</xsl:template>

<!-- Space between paper border and content (chaotic stuff, don't touch) -->
<xsl:param name="page.margin.top">15mm</xsl:param>
<xsl:param name="region.before.extent">10mm</xsl:param>
<xsl:param name="body.margin.top">15mm</xsl:param>

<xsl:param name="body.margin.bottom">15mm</xsl:param>
<xsl:param name="region.after.extent">10mm</xsl:param>
<xsl:param name="page.margin.bottom">15mm</xsl:param>

<xsl:param name="page.margin.outer">19mm</xsl:param>
<xsl:param name="page.margin.inner">31mm</xsl:param>

<xsl:param name="body.start.indent">
  <xsl:choose>
    <xsl:when test="$fop.extensions != 0">0pt</xsl:when>
    <xsl:when test="$fop1.extensions != 0">0pt</xsl:when>
    <xsl:when test="$passivetex.extensions != 0">0pt</xsl:when>
    <xsl:otherwise>4pc</xsl:otherwise>
  </xsl:choose>
</xsl:param>

<xsl:attribute-set name="below.title.properties" use-attribute-sets="formal.title.properties">
	<xsl:attribute name="font-weight">normal</xsl:attribute>
	<xsl:attribute name="font-size">
		<xsl:value-of select="$body.font.master"/>
		<xsl:text>pt</xsl:text>
	</xsl:attribute>
	<xsl:attribute name="space-before.optimum"><xsl:text>0.1pt</xsl:text></xsl:attribute>
	<xsl:attribute name="space-before.minimum"><xsl:text>0.1pt</xsl:text></xsl:attribute>
	<xsl:attribute name="space-before.maximum"><xsl:text>0.1pt</xsl:text></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="above.title.properties" use-attribute-sets="formal.title.properties">
	<xsl:attribute name="font-weight">normal</xsl:attribute>
	<xsl:attribute name="font-size">
		<xsl:value-of select="$body.font.master"/>
		<xsl:text>pt</xsl:text>
	</xsl:attribute>
	<xsl:attribute name="space-before.optimum"><xsl:text>2em</xsl:text></xsl:attribute>
	<xsl:attribute name="space-before.minimum"><xsl:text>2em</xsl:text></xsl:attribute>
	<xsl:attribute name="space-before.maximum"><xsl:text>2em</xsl:text></xsl:attribute>
	<xsl:attribute name="space-after.optimum"><xsl:text>0.1pt</xsl:text></xsl:attribute>
	<xsl:attribute name="space-after.minimum"><xsl:text>0.1pt</xsl:text></xsl:attribute>
	<xsl:attribute name="space-after.maximum"><xsl:text>0.1pt</xsl:text></xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.level1.properties">
	<xsl:attribute name="color"><xsl:value-of select="$title.color"/></xsl:attribute>
	<xsl:attribute name="font-size">
		<xsl:value-of select="$body.font.master * 1.6"/>
		<xsl:text>pt</xsl:text>
	</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.level2.properties">
	<xsl:attribute name="color"><xsl:value-of select="$title.color"/></xsl:attribute>
	<xsl:attribute name="font-size">
		<xsl:value-of select="$body.font.master * 1.4"/>
		<xsl:text>pt</xsl:text>
	</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.level3.properties">
	<xsl:attribute name="color"><xsl:value-of select="$title.color"/></xsl:attribute>
	<xsl:attribute name="font-size">
		<xsl:value-of select="$body.font.master * 1.3"/>
		<xsl:text>pt</xsl:text>
	</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.level4.properties">
	<xsl:attribute name="color"><xsl:value-of select="$title.color"/></xsl:attribute>
	<xsl:attribute name="font-size">
		<xsl:value-of select="$body.font.master * 1.2"/>
		<xsl:text>pt</xsl:text>
	</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.level5.properties">
	<xsl:attribute name="color"><xsl:value-of select="$title.color"/></xsl:attribute>
	<xsl:attribute name="font-size">
		<xsl:value-of select="$body.font.master * 1.1"/>
		<xsl:text>pt</xsl:text>
	</xsl:attribute>
</xsl:attribute-set>
<xsl:attribute-set name="section.title.level6.properties">
	<xsl:attribute name="color"><xsl:value-of select="$title.color"/></xsl:attribute>
	<xsl:attribute name="font-size">
		<xsl:value-of select="$body.font.master"/>
		<xsl:text>pt</xsl:text>
	</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="section.title.properties">
	<xsl:attribute name="font-family">
		<xsl:value-of select="$title.font.family"/>
	</xsl:attribute>
	<xsl:attribute name="font-weight">bold</xsl:attribute>
	<!-- font size is calculated dynamically by section.heading template -->
	<xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
	<xsl:attribute name="space-before.minimum">1.8em</xsl:attribute>
	<xsl:attribute name="space-before.optimum">2.0em</xsl:attribute>
	<xsl:attribute name="space-before.maximum">2.2em</xsl:attribute>
	<xsl:attribute name="space-after.minimum">0.1em</xsl:attribute>
	<xsl:attribute name="space-after.optimum">0.1em</xsl:attribute>
	<xsl:attribute name="space-after.maximum">0.1em</xsl:attribute>
	<xsl:attribute name="text-align">left</xsl:attribute>
	<xsl:attribute name="start-indent">
		<xsl:choose>
			<xsl:when test="ancestor::itemizedlist"><xsl:text>body-start()</xsl:text></xsl:when>
			<xsl:otherwise><xsl:value-of select="$title.margin.left"/></xsl:otherwise>
		</xsl:choose>
	</xsl:attribute>
</xsl:attribute-set>

<xsl:attribute-set name="normal.para.spacing">
	<xsl:attribute name="space-before.minimum">0.1em</xsl:attribute>
	<xsl:attribute name="space-before.optimum">0.1em</xsl:attribute>
	<xsl:attribute name="space-before.maximum">0.1em</xsl:attribute>
	<xsl:attribute name="space-after.optimum">1em</xsl:attribute>
	<xsl:attribute name="space-after.minimum">0.8em</xsl:attribute>
	<xsl:attribute name="space-after.maximum">1.2em</xsl:attribute>
</xsl:attribute-set>

<xsl:template match="question">
  <xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>

  <xsl:variable name="entry.id">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="parent::*"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="deflabel">
    <xsl:choose>
      <xsl:when test="ancestor-or-self::*[@defaultlabel]">
        <xsl:value-of select="(ancestor-or-self::*[@defaultlabel])[last()]
                              /@defaultlabel"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$qanda.defaultlabel"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <fo:list-item id="{$entry.id}" xsl:use-attribute-sets="dash.list.item.spacing">
    <fo:list-item-label end-indent="label-end()">
      <xsl:choose>
        <xsl:when test="$deflabel = 'none'">
          <fo:block/>
        </xsl:when>
        <xsl:otherwise>
          <fo:block font-weight="bold">
            <xsl:apply-templates select="." mode="label.markup"/>
            <xsl:if test="$deflabel = 'number' and not(label)">
              <xsl:apply-templates select="." mode="intralabel.punctuation"/>
            </xsl:if>
          </fo:block>
        </xsl:otherwise>
      </xsl:choose>
    </fo:list-item-label>
    <fo:list-item-body start-indent="body-start()">
      <xsl:choose>
        <xsl:when test="$deflabel = 'none'">
          <fo:block font-weight="bold">
            <xsl:apply-templates select="*[local-name(.)!='label']"/>
          </fo:block>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="*[local-name(.)!='label']"/>
        </xsl:otherwise>
      </xsl:choose>
      <!-- Uncomment this line to get revhistory output in the question -->
      <!-- <xsl:apply-templates select="preceding-sibling::revhistory"/> -->
    </fo:list-item-body>
  </fo:list-item>
</xsl:template>

<!--
From: fo/qandaset.xsl
Reason: Id in list-item-label causes fop crash
Version:1.72
-->
<xsl:template match="answer">
  <xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>
  <xsl:variable name="entry.id">
    <xsl:call-template name="object.id">
      <xsl:with-param name="object" select="parent::*"/>
    </xsl:call-template>
  </xsl:variable>

  <xsl:variable name="deflabel">
    <xsl:choose>
      <xsl:when test="ancestor-or-self::*[@defaultlabel]">
        <xsl:value-of select="(ancestor-or-self::*[@defaultlabel])[last()]
                              /@defaultlabel"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$qanda.defaultlabel"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <fo:list-item xsl:use-attribute-sets="fat.list.item.spacing">
    <fo:list-item-label end-indent="label-end()">
      <xsl:choose>
        <xsl:when test="$deflabel = 'none'">
          <fo:block/>
        </xsl:when>
        <xsl:otherwise>
          <fo:block font-weight="bold">
            <xsl:variable name="answer.label">
              <xsl:apply-templates select="." mode="label.markup"/>
            </xsl:variable>
            <xsl:copy-of select="$answer.label"/>
          </fo:block>
        </xsl:otherwise>
      </xsl:choose>
    </fo:list-item-label>
    <fo:list-item-body start-indent="body-start()">
      <xsl:apply-templates select="*[local-name(.)!='label']"/>
    </fo:list-item-body>
  </fo:list-item>
</xsl:template>

<xsl:template match="d:programlisting|d:screen|d:synopsis">
  <xsl:param name="suppress-numbers" select="'0'"/>
  <xsl:variable name="id"><xsl:call-template name="object.id"/></xsl:variable>

  <xsl:variable name="content">
    <xsl:choose>
      <xsl:when test="$suppress-numbers = '0'
                      and @linenumbering = 'numbered'
                      and $use.extensions != '0'
                      and $linenumbering.extension != '0'">
        <xsl:call-template name="number.rtf.lines">
          <xsl:with-param name="rtf">
            <xsl:choose>
              <xsl:when test="$highlight.source != 0">
                <xsl:call-template name="apply-highlighting"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:apply-templates/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$highlight.source != 0">
            <xsl:call-template name="apply-highlighting"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="block.content">
    <xsl:choose>
      <xsl:when test="$shade.verbatim != 0">
        <fo:block id="{$id}"
             xsl:use-attribute-sets="monospace.verbatim.properties shade.verbatim.style">
          <xsl:choose>
            <xsl:when test="$hyphenate.verbatim != 0 and 
                            $exsl.node.set.available != 0">
              <xsl:apply-templates select="exsl:node-set($content)" 
                                   mode="hyphenate.verbatim"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="exsl:node-set($content)" 
mode="hyphenate"/>
            </xsl:otherwise>
          </xsl:choose>
        </fo:block>
      </xsl:when>
      <xsl:otherwise>
        <fo:block id="{$id}"
                  xsl:use-attribute-sets="monospace.verbatim.properties">
          <xsl:choose>
            <xsl:when test="$hyphenate.verbatim != 0 and 
                            $exsl.node.set.available != 0">
              <xsl:apply-templates select="exsl:node-set($content)" 
                                   mode="hyphenate.verbatim"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:copy-of select="$content"/>
            </xsl:otherwise>
          </xsl:choose>
        </fo:block>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:choose>
    <!-- Need a block-container for these features -->
    <xsl:when test="@width != '' or
                    (self::d:programlisting and
                    starts-with($writing.mode, 'rl'))">
      <fo:block-container start-indent="0pt" end-indent="0pt">
        <xsl:if test="@width != ''">
          <xsl:attribute name="width">
            <xsl:value-of select="concat(@width, '*', $monospace.verbatim.font.width)"/>
          </xsl:attribute>
        </xsl:if>
        <!-- All known program code is left-to-right -->
        <xsl:if test="self::d:programlisting and
                      starts-with($writing.mode, 'rl')">
          <xsl:attribute name="writing-mode">lr-tb</xsl:attribute>
        </xsl:if>
        <xsl:copy-of select="$block.content"/>
      </fo:block-container>
    </xsl:when>
    <xsl:otherwise>
      <xsl:copy-of select="$block.content"/>
    </xsl:otherwise>
  </xsl:choose>

</xsl:template>


<xsl:template match="text()" mode="hyphenate" priority="2">
   <xsl:call-template name="string.subst">
     <xsl:with-param name="string">
       <xsl:call-template name="string.subst">
         <xsl:with-param name="string">
           <xsl:call-template name="string.subst">
             <xsl:with-param name="string" select="."/>
             <xsl:with-param name="target" select="'****'"/>
             <xsl:with-param name="replacement" select="'****&#x200B;'"/>
           </xsl:call-template>
         </xsl:with-param>
         <xsl:with-param name="target" select="'mmmm'"/>
         <xsl:with-param name="replacement" select="'mmmm&#x200B;'"/>
       </xsl:call-template>
     </xsl:with-param>
     <xsl:with-param name="target" select="':'"/>
     <xsl:with-param name="replacement" select="'&#x200B;:'"/>
   </xsl:call-template>
</xsl:template>

<xsl:template match="node()|@*" mode="hyphenate">
   <xsl:copy>
     <xsl:apply-templates select="node()|@*" mode="hyphenate"/>
   </xsl:copy>
</xsl:template>


</xsl:stylesheet>  

