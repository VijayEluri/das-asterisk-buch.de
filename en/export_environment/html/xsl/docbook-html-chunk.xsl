<?xml version="1.0"?>
<xsl:stylesheet	 
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:exsl="http://exslt.org/common"
	xmlns:set="http://exslt.org/sets"
	xmlns:db="http://docbook.org/ns/docbook"
	xmlns="http://www.w3.org/1999/xhtml"
	exclude-result-prefixes="db exsl set"
	version="1.0"
	>
<!--<![CDATA[
################################################################
#  Parameter und Anpassungen fuer das DocBook-Stylesheet.
#  Autor: Philipp Kempgen <philipp.kempgen@amooma.de>
#  Copyright 2010, Amooma GmbH
################################################################
]]>-->

<!--<![CDATA[
################################################################
#  Import the appropriate DocBook stylesheet (HTML, chunking):
################################################################
]]>-->
<!--<![CDATA[
<xsl:import href="/usr/share/xml/docbook/stylesheet/docbook-xsl-ns/xhtml/chunk.xsl" />
]]>-->
<xsl:import href="http://docbook.sourceforge.net/release/xsl-ns/current/xhtml/chunk.xsl" />
<!--<![CDATA[
The URI
"http://docbook.sourceforge.net/release/xsl-ns/current/"
is likely to be mapped to
"file:///usr/share/xml/docbook/stylesheet/docbook-xsl-ns/"
by the local XML catalog.
Use the shell command in following to check:
xmlcatalog /etc/xml/catalog http://docbook.sourceforge.net/release/xsl-ns/current/xhtml/chunk.xsl
]]>-->

<!--<![CDATA[
################################################################
#  Set stylesheet parameters:
################################################################
]]>-->

<xsl:param name="chunker.output.method" select="'xml'" />
<xsl:param name="chunker.output.indent" select="'no'" />
<!-- Do not indent the output. Otherwise those crappy templates would add whitespace in <pre> elements. -->
<xsl:param name="chunker.output.encoding" select="'UTF-8'" />
<xsl:param name="chunker.output.omit-xml-declaration" select="'yes'" />
<xsl:param name="chunker.output.media-type" select="'html'" />
<xsl:param name="chunker.output.doctype-public" select="'-//W3C//DTD XHTML 1.0 Transitional//EN'" />
<xsl:param name="chunker.output.doctype-system" select="'http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd'" />

<xsl:param name="use.id.as.filename" select="1" />

<xsl:param name="html.ext" select="'.html'" />

<xsl:param name="html.stylesheet" select="'css/style.css'" />

<xsl:param name="img.src.path" select="'img/'" />

<xsl:param name="admon.graphics" select="0" />
<xsl:param name="admon.textlabel" select="1" />
<xsl:param name="admon.graphics.extension" select="'.gif'" />
<xsl:param name="admon.graphics.path" select="'dbkimg/'" />
<xsl:param name="admon.style"></xsl:param>

<xsl:param name="navig.graphics" select="1" />
<xsl:param name="navig.graphics.extension" select="'.gif'" />
<xsl:param name="navig.graphics.path" select="'dbkimg/'" />
<xsl:param name="navig.showtitles" select="1" />

<xsl:param name="callout.graphics" select="0" />
<xsl:param name="callout.graphics.extension" select="'.gif'" />
<xsl:param name="callout.graphics.path" select="'dbkimg/'" />
<xsl:param name="callout.graphics.number.limit" select="15" />
<xsl:param name="callout.unicode" select="0" />

<xsl:param name="use.role.for.mediaobject" select="1" />
<xsl:param name="preferred.mediaobject.role" select="'html'" />

<xsl:param name="chunk.first.sections" select="0" />
<xsl:param name="chunk.section.depth" select="1" />

<xsl:param name="toc.section.depth" select="2" />
<xsl:param name="toc.max.depth" select="3" />
<xsl:param name="generate.section.toc.level" select="10" />
<xsl:param name="toc.list.type" select="'dl'" />

<xsl:param name="section.autolabel.max.depth" select="1" />
<xsl:param name="label.from.part" select="1" />
<xsl:param name="section.label.includes.component.label" select="1" />
<xsl:param name="component.label.includes.part.label" select="1" />

<xsl:param name="part.autolabel" select="'I'" />
<xsl:param name="chapter.autolabel" select="'1'" />
<xsl:param name="section.autolabel" select="'1'" />
<xsl:param name="appendix.autolabel" select="'A'" />
<xsl:param name="preface.autolabel" select="'i'" />
<xsl:param name="reference.autolabel" select="'I'" />
<xsl:param name="footnote.number.format" select="'1'" />
<xsl:param name="table.footnote.number.format" select="'a'" />

<xsl:param name="autotoc.label.in.hyperlink" select="0" />
<xsl:param name="autotoc.label.separator" select="'.&#xA0; '" />

<xsl:param name="html.extra.head.links" select="0" />
<xsl:param name="ulink.target" select="'_blank'" />
<xsl:param name="css.decoration" select="0" />
<xsl:param name="html.longdesc" select="0" />
<xsl:param name="generate.meta.abstract" select="1" />

<xsl:param name="generate.index" select="1" />

<xsl:param name="id.warnings" select="1" />

<xsl:param name="generate.manifest" select="1" />
<xsl:param name="manifest" select="'HTML.manifest'" />
<xsl:param name="manifest.in.base.dir" select="0" />

<xsl:param name="generate.legalnotice.link" select="1" />
<xsl:param name="html.head.legalnotice.link.types" select="'copyright license'" />
<xsl:param name="html.head.legalnotice.link.multiple" select="0" />

<xsl:param name="html.cellspacing" select="'1'" />

<xsl:param name="header.rule" select="1" />
<xsl:param name="footer.rule" select="1" />

<xsl:param name="inherit.keywords" select="0" />

<xsl:param name="make.valid.html" select="1" />
<xsl:param name="html.cleanup" select="1" />

<!--<![CDATA[ <xsl:param name="insert.xref.page.number" select="'yes'" /> ]]>-->
<!--<![CDATA[ <xsl:param name="insert.olink.page.number" select="'yes'" /> ]]>-->
<xsl:param name="insert.olink.pdf.frag" select="1" />
<xsl:param name="targets.filename" select="'link-target.db.xml'" />
<xsl:param name="target.database.document" select="'link-olinkdb.xml'" />
<xsl:param name="collect.xref.targets" select="'yes'" />
<xsl:param name="olink.doctitle" select="'yes'" />
<xsl:param name="prefer.internal.olink" select="0" />

<xsl:param name="generate.toc">
appendix  toc,title
article/appendix  nop
article   toc,title
book      toc,title,figure,table,example,equation
chapter   toc,title
part      toc,title
preface   toc,title
qandadiv  toc
qandaset  toc
reference toc,title
sect1     toc,title
sect2     toc,title
sect3     toc,title
sect4     toc,title
sect5     toc,title
section   toc,title
set       toc,title
</xsl:param>

<xsl:param name="use.extensions" select="1"></xsl:param>
<xsl:param name="tablecolumns.extension" select="0"></xsl:param><!-- because "No adjustColumnWidths function available." -->
<xsl:param name="html.extra.head.links.refentry" select="0" /><!-- non-standard param -->





<xsl:template match="*" mode="x.titleabbrev.markup.textonly">
	<xsl:variable name="titleabbrev">
		<xsl:apply-templates select="." mode="titleabbrev.markup"/>
	</xsl:variable>
	<xsl:value-of select="normalize-space($titleabbrev)"/>
</xsl:template>

<!--<![CDATA[
################################################################
#  Template to generate "breadcrumbs":
################################################################
]]>-->
<xsl:template name="breadcrumbs">
	<xsl:param name="this.node" select="." />
	<div class="breadcrumbs">
		<xsl:for-each select="$this.node/ancestor::*">
			<span class="breadcrumb-parent">
				<a>
					<xsl:attribute name="href">
						<xsl:call-template name="href.target">
							<xsl:with-param name="object" select="." />
							<xsl:with-param name="context" select="$this.node" />
						</xsl:call-template>
					</xsl:attribute>
					<!--<![CDATA[ <xsl:apply-templates select="." mode="title.markup" /> ]]>-->
					<!--<![CDATA[ <xsl:apply-templates select="." mode="title.markup.textonly" /> ]]>-->
					<!--<![CDATA[ <xsl:apply-templates select="." mode="titleabbrev.markup" /> ]]>-->
					<xsl:apply-templates select="." mode="x.titleabbrev.markup.textonly" />
				</a>
			</span>
			<xsl:text> &#x2192; </xsl:text>
		</xsl:for-each>
		<!-- And display the current node, but not as a link -->
		<span class="breadcrumb-self">
			<!--<![CDATA[ <xsl:apply-templates select="$this.node" mode="title.markup" /> ]]>-->
			<xsl:apply-templates select="." mode="x.titleabbrev.markup.textonly" />
		</span>
	</div>
</xsl:template>

<!--<![CDATA[
################################################################
#  Call the "breadcrumbs" template for one of "user.header.navigation",
#  "user.header.content" or override "header.navigation":
################################################################
]]>-->
<xsl:template name="user.header.navigation">
	<xsl:call-template name="breadcrumbs" />
</xsl:template>







</xsl:stylesheet>

