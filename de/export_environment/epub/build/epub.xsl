<?xml version='1.0'?>
<!--
	Copyright (c) 2009 Red Hat, Inc.
	License: GPLv2+ or Artistic
	Author: Jeff Fearn <jfearn@redhat.com>
-->


<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml"
				xmlns:exsl="http://exslt.org/common"
				version="1.0"
				exclude-result-prefixes="exsl">

<xsl:import href="deps.xsl"/>

<xsl:param name="tablecolumns.extensions" select="0"/>

<xsl:param name="generate.legalnotice.link" select="0"/>
<xsl:param name="generate.revhistory.link" select="0"/>

<xsl:param name="chunk.section.depth" select="1"/>
<xsl:param name="chunk.first.sections" select="1"/>
<xsl:param name="chunk.toc" select="''"/>
<xsl:param name="chunk.append"/>
<xsl:param name="chunker.output.quiet" select="0"/>
<xsl:param name="base.dir">html/</xsl:param>
<xsl:param name="use.id.as.filename" select="1"/>
<xsl:param name="prod.url">http://www.wintermeyer.de/</xsl:param>
<xsl:param name="doc.url">http://www.wintermeyer.de/</xsl:param>
<xsl:param name="default.image.width" select="'500px'"/>
<xsl:param name="generate.toc">
set toc
book toc
article toc
chapter toc
part toc
section nop
set nop
sect1 nop
sect2 nop
sect3 nop
sect4 nop
sect5 nop
qandadiv nop
qandaset nop
</xsl:param>

<!-- Admonitions -->
<xsl:param name="admon.graphics" select="1"/>

</xsl:stylesheet>
