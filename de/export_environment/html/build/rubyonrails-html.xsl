<?xml version='1.0'?>
 
<!--
	Copyright (c) 2007-2009 Red Hat, Inc.
	License: GPLv2+ or Artistic
	Author: Jeff Fearn <jfearn@redhat.com>
	Author: Tammy Fox <tfox@redhat.com>
	Author: Andy Fitzsimon <afitzsim@redhat.com>
-->

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns="http://www.w3.org/1999/xhtml" xmlns:xlink="http://www.w3.org/1999/xlink" xmlns:d="http://docbook.org/ns/docbook" xmlns:suwl="http://nwalsh.com/xslt/ext/com.nwalsh.saxon.UnwrapLinks" xmlns:exsl="http://exslt.org/common" version="1.0" exclude-result-prefixes="exsl">
	
	<xsl:import href="deps.xsl"/>
	
	<xsl:include href="defaults.xsl"/>
	<xsl:include href="xhtml-common.xsl"/>
	
	<xsl:param name="generate.legalnotice.link" select="0"/>
	<xsl:param name="generate.revhistory.link" select="0"/>
	
	<xsl:param name="chunk.section.depth" select="1"/>
	<xsl:param name="chunk.first.sections" select="1"/>
	<xsl:param name="section.autolabel.max.depth" select="2"/>
	<xsl:param name="chunk.toc" select="''"/>
	<xsl:param name="chunk.append"/>
	<xsl:param name="chunker.output.quiet" select="0"/>
<!--<xsl:param name="base.dir">html/</xsl:param>-->
	<xsl:param name="use.id.as.filename" select="1"/>
	<xsl:param name="prod.url">http://www.wintermeyer.de/</xsl:param>
	<xsl:param name="doc.url">http://www.wintermeyer.de/</xsl:param>
	<xsl:param name="default.image.width" select="'700px'"/>
	<xsl:param name="navig.showtitles" select="1"/>
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
	
	
	<xsl:param name="admon.graphics" select="1"/>
	<xsl:param name="admon.graphics.extension">.png</xsl:param>
	<xsl:param name="admon.graphics.path">custom-admons-callouts/</xsl:param>
	
	<xsl:param name="callout.graphics" select="1"/>
	<xsl:param name="callout.graphics.extension">.png</xsl:param>
	<xsl:param name="callout.graphics.path">custom-admons-callouts/callouts/</xsl:param>


<!--<xsl:param name="embedtoc" select="1"/>-->

<!--
From: xsl/docbook/1.72.0/xhtml/chunk-code.xsl
Reason: remove inline css from hr
Version: 1.72.0
-->
	<xsl:template name="process.footnotes">
		<xsl:variable name="footnotes" select=".//footnote"/>
		<xsl:variable name="fcount">
			<xsl:call-template name="count.footnotes.in.this.chunk">
				<xsl:with-param name="node" select="."/>
				<xsl:with-param name="footnotes" select="$footnotes"/>
			</xsl:call-template>
		</xsl:variable>

<!--
  <xsl:message>
    <xsl:value-of select="name(.)"/>
    <xsl:text> fcount: </xsl:text>
    <xsl:value-of select="$fcount"/>
  </xsl:message>
-->

  <!-- Only bother to do this if there's at least one non-table footnote -->
		<xsl:if test="$fcount &gt; 0">
			<div class="footnotes" xmlns="http://www.w3.org/1999/xhtml">
				<br/>
				<hr/>
				<xsl:call-template name="process.footnotes.in.this.chunk">
					<xsl:with-param name="node" select="."/>
					<xsl:with-param name="footnotes" select="$footnotes"/>
				</xsl:call-template>
			</div>
		</xsl:if>

  <!-- FIXME: When chunking, only the annotations actually used
              in this chunk should be referenced. I don't think it
              does any harm to reference them all, but it adds
              unnecessary bloat to each chunk. -->
		<xsl:if test="$annotation.support != 0 and //annotation">
			<div class="annotation-list">
				<div class="annotation-nocss">
					<p>The following annotations are from this essay. You are seeing
        them here because your browser doesn&#8217;t support the user-interface
        techniques used to make them appear as &#8216;popups&#8217; on modern browsers.</p>
				</div>
				
				<xsl:apply-templates select="//annotation" mode="annotation-popup"/>
			</div>
		</xsl:if>
	</xsl:template>
<!--
From: xhtml/chunk-common.xsl
Reason: remove tables, truncate link text
Version:
-->
	<xsl:template name="header.navigation">
		<xsl:param name="prev" select="/foo"/>
		<xsl:param name="next" select="/foo"/>
		<xsl:param name="nav.context"/>
		<xsl:variable name="home" select="/*[1]"/>
		<xsl:variable name="up" select="parent::*"/>
		<xsl:variable name="row1" select="$navig.showtitles != 0"/>
		<xsl:variable name="row2" select="count($prev) &gt; 0 or (count($up) &gt; 0 and generate-id($up) != generate-id($home) and $navig.showtitles != 0) or count($next) &gt; 0"/>
		<xsl:if test="$suppress.navigation = '0' and $suppress.header.navigation = '0'">
			<xsl:if test="$row1 or $row2">
				<xsl:if test="$row1"></xsl:if>
				<xsl:if test="$row2">
					<ul class="docnav top" xmlns="http://www.w3.org/1999/xhtml">
						<li class="previous">
							<xsl:if test="count($prev)&gt;0">
								<a accesskey="p">
									<xsl:attribute name="href">
										<xsl:call-template name="href.target">
											<xsl:with-param name="object" select="$prev"/>
										</xsl:call-template>
									</xsl:attribute>
									<strong>
										<xsl:call-template name="navig.content">
											<xsl:with-param name="direction" select="'prev'"/>
										</xsl:call-template>
									</strong>
								</a>
							</xsl:if>
						</li>
						<li class="maintitle">
							<h1 class="booktitle">
								<a>
									<xsl:attribute name="href">
										<xsl:call-template name="href.target">
											<xsl:with-param name="object" select="(ancestor::node())[1]"/>
											<!--<xsl:with-param name="context" select="$this.node"/>-->
										</xsl:call-template>
									</xsl:attribute>
									<xsl:apply-templates select="(ancestor::node())[1]" mode="title.markup"/>
								</a>
								<!--<xsl:apply-templates select="(ancestor::node())[1]" mode="object.title.markup"/>-->
							</h1>
						</li>
						<li class="next">
							<xsl:if test="count($next)&gt;0">
								<a accesskey="n">
									<xsl:attribute name="href">
										<xsl:call-template name="href.target">
											<xsl:with-param name="object" select="$next"/>
										</xsl:call-template>
									</xsl:attribute>
									<strong>
										<xsl:call-template name="navig.content">
											<xsl:with-param name="direction" select="'next'"/>
										</xsl:call-template>
									</strong>
								</a>
							</xsl:if>
						</li>
					</ul>
				</xsl:if>
			</xsl:if>
			<xsl:if test="$header.rule != 0">
				<hr/>
			</xsl:if>
		</xsl:if>
	</xsl:template>

<!--
From: xhtml/chunk-common.xsl
Reason: remove tables, truncate link text
Version:
-->
	<xsl:template name="footer.navigation">
		<xsl:param name="prev" select="/foo"/>
		<xsl:param name="next" select="/foo"/>
		<xsl:param name="nav.context"/>
		<xsl:param name="title-limit" select="'50'"/>
		<xsl:variable name="home" select="/*[1]"/>
		<xsl:variable name="up" select="parent::*"/>
		<xsl:variable name="row1" select="count($prev) &gt; 0 or count($up) &gt; 0 or count($next) &gt; 0"/>
		<xsl:variable name="row2" select="($prev and $navig.showtitles != 0) or (generate-id($home) != generate-id(.) or $nav.context = 'toc') or ($chunk.tocs.and.lots != 0 and $nav.context != 'toc') or ($next and $navig.showtitles != 0)"/>
		
		<xsl:if test="$suppress.navigation = '0' and $suppress.footer.navigation = '0'">
			<xsl:if test="$footer.rule != 0">
				<hr/>
			</xsl:if>
			<xsl:if test="$row1 or $row2">
				<ul class="docnav bottom" xmlns="http://www.w3.org/1999/xhtml">
					<xsl:if test="$row1">
						<li class="previous">
							<xsl:if test="count($prev) &gt; 0">
								<a accesskey="p">
									<xsl:attribute name="href">
										<xsl:call-template name="href.target">
											<xsl:with-param name="object" select="$prev"/>
										</xsl:call-template>
									</xsl:attribute>
									<strong>
										<xsl:call-template name="navig.content">
											<xsl:with-param name="direction" select="'prev'"/>
										</xsl:call-template>
									</strong>
									<xsl:variable name="text">
										<xsl:apply-templates select="$prev" mode="object.title.markup"/>
									</xsl:variable>
									<xsl:choose>
										<xsl:when test="string-length($text) &gt; $title-limit">
											<xsl:value-of select="concat(substring($text, 0, $title-limit), '...')"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$text"/>
										</xsl:otherwise>
									</xsl:choose>
								</a>
							</xsl:if>
						</li>
						<xsl:if test="count($up) &gt; 0">
							<li class="up">
								<a accesskey="u">
									<xsl:attribute name="href">
										<xsl:text>#</xsl:text>
									</xsl:attribute>
									<strong>
										<xsl:call-template name="navig.content">
											<xsl:with-param name="direction" select="'up'"/>
										</xsl:call-template>
									</strong>
								</a>
							</li>
						</xsl:if>
						<xsl:if test="$home != . or $nav.context = 'toc'">
							<li class="home">
								<a accesskey="h">
									<xsl:attribute name="href">
										<xsl:call-template name="href.target">
											<xsl:with-param name="object" select="$home"/>
										</xsl:call-template>
									</xsl:attribute>
									<strong>
										<xsl:call-template name="navig.content">
											<xsl:with-param name="direction" select="'home'"/>
										</xsl:call-template>
									</strong>
								</a>
							</li>
						</xsl:if>
						<xsl:if test="count($next)&gt;0">
							<li class="next">
								<a accesskey="n">
									<xsl:attribute name="href">
										<xsl:call-template name="href.target">
											<xsl:with-param name="object" select="$next"/>
										</xsl:call-template>
									</xsl:attribute>
									<strong>
										<xsl:call-template name="navig.content">
											<xsl:with-param name="direction" select="'next'"/>
										</xsl:call-template>
									</strong>
									<xsl:variable name="text">
										<xsl:apply-templates select="$next" mode="object.title.markup"/>
									</xsl:variable>
									<xsl:choose>
										<xsl:when test="string-length($text) &gt; $title-limit">
											<xsl:value-of select="concat(substring($text, 0, $title-limit),'...')"/>
										</xsl:when>
										<xsl:otherwise>
											<xsl:value-of select="$text"/>
										</xsl:otherwise>
									</xsl:choose>
								</a>
							</li>
						</xsl:if>
					</xsl:if>
				</ul>
				<ul class="footer">
					<li class="copyright">
						Copyright © 2010 <a class="twitter-link" rel="me" href="http://www.twitter.com/wintermeyer" title="Stefan Wintermeyer"><span>Stefan Wintermeyer</span>
						</a>.
					</li>
					<li class="designer">
						<a rel="colleague" class="designer-link" href="http://www.humbug.in." title="Docbook Conversion and Design by Pratik Sinha">
							<span>Docbook Conversion and Design by Pratik Sinha</span>
						</a>
					</li>
				</ul>
			</xsl:if>
		</xsl:if>
	</xsl:template>

<!--
From: xhtml/chunk-common.xsl
Reason: add TOC div for web site
Version:
-->
	<xsl:template name="chunk-element-content">
		<xsl:param name="prev"/>
		<xsl:param name="next"/>
		<xsl:param name="nav.context"/>
		<xsl:param name="content">
			<xsl:apply-imports/>
		</xsl:param>
		
		<xsl:call-template name="user.preroot"/>
		
		<html>
			<xsl:call-template name="html.head">
				<xsl:with-param name="prev" select="$prev"/>
				<xsl:with-param name="next" select="$next"/>
			</xsl:call-template>
			
			<body id="your-body">
				<xsl:call-template name="body.attributes"/>
				<xsl:if test="$embedtoc != 0">
					<div id="tocdiv" class="toc">
						<object>
							<xsl:attribute name="id">tocframe</xsl:attribute>
							<xsl:attribute name="class">toc</xsl:attribute>
							<xsl:attribute name="data">
								<xsl:value-of select="$l10n.gentext.language"/>index.html</xsl:attribute>
							<xsl:attribute name="type">text/html</xsl:attribute>
						</object>
					</div>
				</xsl:if>
				<div id="content">
					<div id="content-inner">
						<div id="rightcol" class="sidebar">
							<xsl:if test="$extrahtml = 1">
								<xsl:if test="count($extrahtmlfile//extrahtml/*) &gt; 0">
									<div id="extrahtml">
										<xsl:copy-of select="$extrahtmlfile/extrahtml/node()"/>
									</div>
								</xsl:if>
							</xsl:if>
							<xsl:call-template name="breadcrumbs"/>
							
							<div id="textsize">
								<span class="textts"> Change Text Size</span>
								<br/>
	<!--<a href="javascript:void(0);" onclick="javascript:body.style.fontSize='9px'"><span class="plusts" style="font-size: xx-small;">+</span></a> <a href="javascript:void(0);" onclick="javascript:body.style.fontSize='11px'"><span class="plusts" style="font-size: x-small;">+</span></a>-->
								<a href="javascript:void(0);" onclick="javascript:body.style.fontSize='13px'">
									<span class="plusts" style="font-size: small;">+</span>
								</a>
								<a href="javascript:void(0);" onclick="javascript:body.style.fontSize='15px'">
									<span class="plusts" style="font-size: large;">+</span>
								</a>
								<a href="javascript:void(0);" onclick="javascript:body.style.fontSize='17px'">
									<span class="plusts" style="font-size: x-large;">+</span>
								</a>
							</div>
							
							
							<div id="amazonad">
								<xsl:element name="iframe">
									<xsl:attribute name="src">http://rcm-de.amazon.de/e/cm?lt1=_top&amp;bc1=FFFFFF&amp;IS2=1&amp;bg1=FFFFFF&amp;fc1=000000&amp;lc1=0000FF&amp;t=wwwamoomade-21&amp;o=3&amp;p=8&amp;l=as1&amp;m=amazon&amp;f=ifr&amp;asins=3827329892</xsl:attribute>
									<xsl:attribute name="style">width:120px;height:240px;</xsl:attribute>
									<xsl:attribute name="scrolling">no</xsl:attribute>
									<xsl:attribute name="marginwidth">0</xsl:attribute>
									<xsl:attribute name="marginheight">0</xsl:attribute>
									<xsl:attribute name="frameborder">0</xsl:attribute>
								</xsl:element>
							</div>
							
							<xsl:if test="$adincluded = 1">
								<div id="adsense">
									<script type="text/javascript">
										<xsl:text disable-output-escaping="yes">
      				<!--ADD YOUR AD INSIDE THE CDATA SECTION-->
					<![CDATA[<!--]]>
				</xsl:text>
										<xsl:copy-of select="$adfile/ad/node()"/>
										<xsl:text disable-output-escaping="yes">
					<![CDATA[//-->]]>
				</xsl:text>
									</script>
									<script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js"></script>
								</div>
							</xsl:if>
							<div id="validator">
								<p>
									<a href="http://validator.w3.org/check?uri=referer">
										<img src="http://www.w3.org/Icons/valid-xhtml10" alt="Valid XHTML 1.0 Strict" height="31" width="88" />
									</a>
								</p>
							</div>
						</div>
						<div id="maincol">
							<xsl:call-template name="user.header.navigation"/>
							<xsl:call-template name="header.navigation">
								<xsl:with-param name="prev" select="$prev"/>
								<xsl:with-param name="next" select="$next"/>
								<xsl:with-param name="nav.context" select="$nav.context"/>
							</xsl:call-template>
							
							<xsl:call-template name="user.header.content"/>
							
							<xsl:copy-of select="$content"/>
							
							<xsl:call-template name="user.footer.content"/>
							
							<xsl:call-template name="footer.navigation">
								<xsl:with-param name="prev" select="$prev"/>
								<xsl:with-param name="next" select="$next"/>
								<xsl:with-param name="nav.context" select="$nav.context"/>
							</xsl:call-template>
							
							<xsl:call-template name="user.footer.navigation"/>
						</div>
						
						<div class="clear"></div>
					</div>
				</div>
				<xsl:if test="$analyticsincluded = 1">
					<xsl:copy-of select="$analyticsfile/analytics/node()"/>
				</xsl:if>
			</body>
		</html>
		<xsl:value-of select="$chunk.append"/>
	</xsl:template>
	
	<xsl:template name="breadcrumbs">
		<xsl:param name="this.node" select="."/>
		<ul class="breadcrumbs">
			<xsl:for-each select="$this.node/ancestor::*">
				<xsl:if test="local-name(.) = 'chapter' or local-name(.) = 'appendix'">
					<xsl:call-template name="print-previous-chapters">
					</xsl:call-template>
				</xsl:if>
				<li>
					<xsl:attribute name="class">
						<xsl:value-of select="local-name(.)"/>
						<xsl:text> breadcrumb-link breadcrumb-first-level</xsl:text>
						<xsl:if test="position() != 1">
							<xsl:text> breadcrumb-bullet </xsl:text>
						</xsl:if>
					</xsl:attribute>
					<xsl:attribute name="style">
						<xsl:text>margin-left: </xsl:text>
						<xsl:choose>
							<xsl:when test="local-name(.) = 'book'">
								<xsl:value-of select="0"/>
							</xsl:when>
							<xsl:when test="local-name(.) = 'chapter'">
								<xsl:value-of select="0"/>
							</xsl:when>
							<xsl:when test="local-name(.) = 'appendix'">
								<xsl:value-of select="0"/>
							</xsl:when>
							<xsl:when test="local-name(.) = 'section'">
								<xsl:value-of select="0.8"/>
							</xsl:when>
							<xsl:otherwise>
								<xsl:value-of select="(position() - 1) * 0.8"/>
							</xsl:otherwise>
						</xsl:choose>
						<xsl:text>em</xsl:text>
					</xsl:attribute>
					<a>
						<xsl:attribute name="href">
							<xsl:call-template name="href.target">
								<xsl:with-param name="object" select="."/>
								<xsl:with-param name="context" select="$this.node"/>
							</xsl:call-template>
						</xsl:attribute>
						<xsl:apply-templates select="." mode="title.markup"/>
					</a>
				</li>
				<xsl:if test="position() = last()">
					<xsl:if test="local-name($this.node) = 'chapter' or local-name($this.node) = 'appendix'">
						<xsl:call-template name="special-print-previous-chapters">
							<xsl:with-param name="node" select="$this.node"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:call-template name="last-li-breadcrumb">
						<xsl:with-param name="padding" select="(position() - 1) * 0.8"/>
						<xsl:with-param name="last-li-node" select="$this.node"/>
					</xsl:call-template>
					<xsl:if test="local-name($this.node) = 'chapter'">
						<xsl:call-template name="special-print-following-chapters">
							<xsl:with-param name="node" select="$this.node"/>
						</xsl:call-template>
					</xsl:if>
					<xsl:call-template name="print-following-chapters">
						<xsl:with-param name="last-li-node" select="$this.node"/>
					</xsl:call-template>
				</xsl:if>
			
			</xsl:for-each>
			<xsl:if test="count($this.node/ancestor::*) = 0">
				<li class="breadcrumb-node breadcrumb-last">
					<xsl:apply-templates select="$this.node" mode="title.markup"/>
				</li>
			</xsl:if>
		
		</ul>
	</xsl:template>
	
	<xsl:template name="print-following-chapters">
		<xsl:param name="last-li-node"/>
		<xsl:for-each select="$last-li-node/ancestor::*[name() = 'chapter' or name() = 'appendix']/following-sibling::*">
			<xsl:if test="local-name(.) = 'chapter' or local-name(.) = 'appendix'">
				<li>
					<xsl:attribute name="class">
						<xsl:text>print-following breadcrumb-link breadcrumb-bullet </xsl:text>
						<xsl:value-of select="local-name(.)"/>
					</xsl:attribute>
					<a>
						<xsl:attribute name="href">
							<xsl:call-template name="href.target">
								<xsl:with-param name="object" select="."/>
							</xsl:call-template>
						</xsl:attribute>
						<xsl:apply-templates select="." mode="title.markup"/>
					</a>
				</li>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="special-print-following-chapters">
		<xsl:param name="node"/>
		<xsl:for-each select="$node/following-sibling::*[name() = 'chapter' or name() = 'appendix']">
			<xsl:if test="local-name(.) = 'chapter' or local-name(.) = 'appendix'">
				<li>
					<xsl:attribute name="class">
						<xsl:text>special-print-following breadcrumb-link breadcrumb-bullet </xsl:text>
						<xsl:value-of select="local-name(.)"/>
					</xsl:attribute>
					<a>
						<xsl:attribute name="href">
							<xsl:call-template name="href.target">
								<xsl:with-param name="object" select="."/>
							</xsl:call-template>
						</xsl:attribute>
						<xsl:apply-templates select="." mode="title.markup"/>
					</a>
				</li>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="print-previous-chapters">
		<xsl:for-each select="preceding-sibling::*">
			<xsl:if test="local-name(.) = 'chapter' or local-name(.) = 'appendix'">
				<li>
					<xsl:attribute name="class">
						<xsl:text>print-previous breadcrumb-link breadcrumb-bullet </xsl:text>
						<xsl:value-of select="local-name(.)"/>
					</xsl:attribute>
					<a>
						<xsl:attribute name="href">
							<xsl:call-template name="href.target">
								<xsl:with-param name="object" select="."/>
							</xsl:call-template>
						</xsl:attribute>
						<xsl:apply-templates select="." mode="title.markup"/>
					</a>
				</li>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	
	<xsl:template name="special-print-previous-chapters">
		<xsl:param name="node"/>
		<xsl:for-each select="$node/preceding-sibling::*">
			<xsl:if test="local-name(.) = 'chapter' or local-name(.) = 'appendix'">
				<li>
					<xsl:attribute name="class">
						<xsl:text>special-print-previous breadcrumb-link breadcrumb-bullet </xsl:text>
						<xsl:value-of select="local-name(.)"/>
					</xsl:attribute>
					<a>
						<xsl:attribute name="href">
							<xsl:call-template name="href.target">
								<xsl:with-param name="object" select="."/>
							</xsl:call-template>
						</xsl:attribute>
						<xsl:apply-templates select="." mode="title.markup"/>
					</a>
				</li>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="last-li-breadcrumb">
		<xsl:param name="last-li-node"/>
		<xsl:param name="padding"/>
<!-- And display the current node, but not as a link -->
		<xsl:for-each select="$last-li-node/preceding-sibling::*[name() = 'section']">
			<li>
				<xsl:attribute name="class">
					<xsl:text>last-li-preceding breadcrumb-link breadcrumb-bullet </xsl:text>
					<xsl:value-of select="local-name(.)"/>
				</xsl:attribute>
				<xsl:attribute name="style">
					<xsl:text>margin-left: </xsl:text>
					<xsl:value-of select="$padding"/>
					<xsl:text>em</xsl:text>
				</xsl:attribute>
				<a>
					<xsl:attribute name="href">
						<xsl:call-template name="href.target">
							<xsl:with-param name="object" select="."/>
						</xsl:call-template>
					</xsl:attribute>
					<xsl:apply-templates select="." mode="title.markup"/>
				</a>
			</li>
		</xsl:for-each>
		<li>
			<xsl:attribute name="class">
				<xsl:text>last-li breadcrumb-node breadcrumb-last breadcrumb-bullet </xsl:text>
				<xsl:value-of select="local-name($last-li-node)"/>
			</xsl:attribute>
			<xsl:choose>
			<xsl:when test="local-name($last-li-node)='chapter' or local-name($last-li-node) = 'appendix'">
			<xsl:attribute name="style">
				<xsl:text>margin-left: 0em</xsl:text>
			</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
			<xsl:attribute name="style">
				<xsl:text>margin-left: </xsl:text>
				<xsl:value-of select="$padding"/>
				<xsl:text>em</xsl:text>
			</xsl:attribute>
			</xsl:otherwise>
			</xsl:choose>
			<xsl:choose>
				<xsl:when test="count($last-li-node/child::*[name()!='para']) = 1">
					<xsl:apply-templates select="$last-li-node" mode="title.markup"/>
				</xsl:when>
				<xsl:otherwise>
					<a>
						<xsl:attribute name="href">
							<xsl:call-template name="href.target">
								<xsl:with-param name="object" select="$last-li-node"/>
							</xsl:call-template>
						</xsl:attribute>
						<xsl:apply-templates select="$last-li-node" mode="title.markup"/>
					</a>
				</xsl:otherwise>
			</xsl:choose>
		</li>
		<xsl:for-each select="$last-li-node/child::*[name()!='para' and position() != 1]">
			<xsl:if test="local-name(.) != 'itemizedlist'">
			<li>
				<xsl:choose>
				<xsl:when test="local-name($last-li-node)='chapter' or local-name($last-li-node) = 'appendix'">
				<xsl:attribute name="class">
					<xsl:text>last-li-link breadcrumb-link breadcrumb-bullet </xsl:text>
					<xsl:value-of select="local-name(.)"/>
				</xsl:attribute>
				<xsl:attribute name="style">
					<xsl:text>margin-left: </xsl:text>
					<xsl:value-of select="$padding + 0.8"/>
					<xsl:text>em</xsl:text>
				</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
				<xsl:attribute name="class">
					<xsl:text>last-li-link breadcrumb-link breadcrumb-bullet-another </xsl:text>
					<xsl:value-of select="local-name(.)"/>
				</xsl:attribute>
				<xsl:attribute name="style">
					<xsl:text>margin-left: </xsl:text>
					<xsl:value-of select="$padding + 0.8 + 0.8"/>
					<xsl:text>em</xsl:text>
				</xsl:attribute>
				</xsl:otherwise>
				</xsl:choose>
				<a>
					<xsl:attribute name="href">
						<xsl:call-template name="href.target">
							<xsl:with-param name="object" select="."/>
							<xsl:with-param name="context" select="$last-li-node"/>
						</xsl:call-template>
					</xsl:attribute>
					<xsl:apply-templates select="." mode="title.markup"/>
				</a>
			</li>
			</xsl:if>
		</xsl:for-each>
		<xsl:for-each select="$last-li-node/following-sibling::*[name()='section']">
			<!--<xsl:if test="count($last-li-node/child::*[name()!='para']) = 1">-->
				<li>
					<xsl:attribute name="class">
						<xsl:text>last-li-following breadcrumb-link breadcrumb-bullet </xsl:text>
						<xsl:value-of select="local-name(.)"/>
					</xsl:attribute>
					<xsl:attribute name="style">
						<xsl:text>margin-left: </xsl:text>
						<xsl:value-of select="$padding"/>
						<xsl:text>em</xsl:text>
					</xsl:attribute>
					<a>
						<xsl:attribute name="href">
							<xsl:call-template name="href.target">
								<xsl:with-param name="object" select="."/>
							</xsl:call-template>
						</xsl:attribute>
						<xsl:apply-templates select="." mode="title.markup"/>
					</a>
				</li>
			<!--</xsl:if>-->
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template name="simple.xlink">
		<xsl:param name="node" select="."/>
		<xsl:param name="content">
			<xsl:apply-templates/>
		</xsl:param>
		<xsl:param name="linkend" select="$node/@linkend"/>
		<xsl:param name="xhref" select="$node/@xlink:href"/>

  <!-- Support for @xlink:show -->
		<xsl:variable name="target.show">
			<xsl:choose>
				<xsl:when test="$node/@xlink:show = 'new'">_blank</xsl:when>
				<xsl:when test="$node/@xlink:show = 'replace'">_top</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="link">
			<xsl:choose>
				<xsl:when test="$xhref and (not($node/@xlink:type) or $node/@xlink:type='simple')">

        <!-- Is it a local idref or a uri? -->
					<xsl:variable name="is.idref">
						<xsl:choose>
            <!-- if the href starts with # and does not contain an "(" -->
            <!-- or if the href starts with #xpointer(id(, it's just an ID -->
							<xsl:when test="starts-with($xhref,'#') and (not(contains($xhref,'(')) or starts-with($xhref, '#xpointer(id('))">1</xsl:when>
							<xsl:otherwise>0</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>

        <!-- Is it an olink ? -->
					<xsl:variable name="is.olink">
						<xsl:choose>
            <!-- If xlink:role="http://docbook.org/xlink/role/olink" -->
            <!-- and if the href contains # -->
							<xsl:when test="contains($xhref,'#') and @xlink:role = $xolink.role">1</xsl:when>
							<xsl:otherwise>0</xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					
					<xsl:choose>
						<xsl:when test="$is.olink = 1">
							<xsl:call-template name="olink">
								<xsl:with-param name="content" select="$content"/>
							</xsl:call-template>
						</xsl:when>
						
						<xsl:when test="$is.idref = 1">
							
							<xsl:variable name="idref">
								<xsl:call-template name="xpointer.idref">
									<xsl:with-param name="xpointer" select="$xhref"/>
								</xsl:call-template>
							</xsl:variable>
							
							<xsl:variable name="targets" select="key('id',$idref)"/>
							<xsl:variable name="target" select="$targets[1]"/>
							
							<xsl:call-template name="check.id.unique">
								<xsl:with-param name="linkend" select="$idref"/>
							</xsl:call-template>
							
							<xsl:choose>
								<xsl:when test="count($target) = 0">
									<xsl:message>
										<xsl:text>XLink to nonexistent id: </xsl:text>
										<xsl:value-of select="$idref"/>
									</xsl:message>
									<xsl:copy-of select="$content"/>
								</xsl:when>
								
								<xsl:otherwise>
									<a>
										<xsl:apply-templates select="." mode="common.html.attributes"/>
										
										<xsl:attribute name="href">
											<xsl:call-template name="href.target">
												<xsl:with-param name="object" select="$target"/>
											</xsl:call-template>
										</xsl:attribute>
										
										<xsl:choose>
											<xsl:when test="$node/@xlink:title">
												<xsl:attribute name="title">
													<xsl:value-of select="$node/@xlink:title"/>
												</xsl:attribute>
											</xsl:when>
											<xsl:otherwise>
												<xsl:apply-templates select="$target" mode="html.title.attribute"/>
											</xsl:otherwise>
										</xsl:choose>
										
										<xsl:if test="$target.show !=''">
											<xsl:attribute name="target">
												<xsl:value-of select="$target.show"/>
											</xsl:attribute>
										</xsl:if>
										
										<xsl:copy-of select="$content"/>
									
									</a>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:when>

          <!-- otherwise it's a URI -->
						<xsl:otherwise>
							<a>
								<xsl:apply-templates select="." mode="common.html.attributes"/>
								<xsl:attribute name="href">
									<xsl:value-of select="$xhref"/>
								</xsl:attribute>
								<xsl:if test="$node/@xlink:title">
									<xsl:attribute name="title">
										<xsl:value-of select="$node/@xlink:title"/>
									</xsl:attribute>
								</xsl:if>

              <!-- For URIs, use @xlink:show if defined, otherwise use ulink.target -->
								<xsl:if test="$target.show !='' or $ulink.target !=''">
									<xsl:attribute name="target">
										<xsl:choose>
											<xsl:when test="$target.show !=''">
												<xsl:value-of select="$target.show"/>
											</xsl:when>
											<xsl:otherwise>
												<xsl:value-of select="$ulink.target"/>
											</xsl:otherwise>
										</xsl:choose>
									</xsl:attribute>
								</xsl:if>
								
								<xsl:copy-of select="$content"/>
							</a>
						</xsl:otherwise>
					</xsl:choose>
				</xsl:when>
				
				<xsl:when test="$linkend">
					<xsl:variable name="targets" select="key('id',$linkend)"/>
					<xsl:variable name="target" select="$targets[1]"/>
					
					<xsl:call-template name="check.id.unique">
						<xsl:with-param name="linkend" select="$linkend"/>
					</xsl:call-template>
					
					<a>
						<xsl:apply-templates select="." mode="common.html.attributes"/>
						<xsl:attribute name="href">
							<xsl:call-template name="href.target">
								<xsl:with-param name="object" select="$target"/>
							</xsl:call-template>
						</xsl:attribute>
						
						<xsl:apply-templates select="$target" mode="html.title.attribute"/>
						
						<xsl:copy-of select="$content"/>
					
					</a>
				</xsl:when>
				<xsl:otherwise>
					<xsl:copy-of select="$content"/>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:choose>
			<xsl:when test="function-available('suwl:unwrapLinks')">
				<xsl:copy-of select="suwl:unwrapLinks($link)"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:copy-of select="$link"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<xsl:template name="process.image.attributes">
		<xsl:param name="alt"/>
		<xsl:param name="html.width"/>
		<xsl:param name="html.depth"/>
		<xsl:param name="longdesc"/>
		<xsl:param name="scale"/>
		<xsl:param name="scalefit"/>
		<xsl:param name="scaled.contentdepth"/>
		<xsl:param name="scaled.contentwidth"/>
		<xsl:param name="viewport"/>
		
		<xsl:choose>
			<xsl:when test="@contentwidth or @contentdepth">
      <!-- ignore @width/@depth, @scale, and @scalefit if specified -->
				<xsl:if test="@contentwidth and $scaled.contentwidth != ''">
					<xsl:attribute name="width">
						<xsl:value-of select="$scaled.contentwidth"/>
					</xsl:attribute>
				</xsl:if>
				<xsl:if test="@contentdepth and $scaled.contentdepth != ''">
					<xsl:attribute name="height">
						<xsl:value-of select="$scaled.contentdepth"/>
					</xsl:attribute>
				</xsl:if>
			</xsl:when>
			
			<xsl:when test="number($scale) != 1.0">
      <!-- scaling is always uniform, so we only have to specify one dimension -->
      <!-- ignore @scalefit if specified -->
				<xsl:attribute name="width">
					<xsl:value-of select="$scaled.contentwidth"/>
				</xsl:attribute>
			</xsl:when>
			
			<xsl:when test="$scalefit != 0">
				<xsl:choose>
					<xsl:when test="contains($html.width, '%')">
						<xsl:choose>
							<xsl:when test="$viewport != 0">
              <!-- The *viewport* will be scaled, so use 100% here! -->
								<xsl:attribute name="width">
									<xsl:value-of select="'100%'"/>
								</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="width">
									<xsl:value-of select="$html.width"/>
								</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					
					<xsl:when test="contains($html.depth, '%')">
          <!-- HTML doesn't deal with this case very well...do nothing --></xsl:when>
					
					<xsl:when test="$scaled.contentwidth != '' and $html.width != '' and $scaled.contentdepth != '' and $html.depth != ''">
          <!-- scalefit should not be anamorphic; figure out which direction -->
          <!-- has the limiting scale factor and scale in that direction -->
						<xsl:choose>
							<xsl:when test="$html.width div $scaled.contentwidth &gt; $html.depth div $scaled.contentdepth">
								<xsl:attribute name="height">
									<xsl:value-of select="$html.depth"/>
								</xsl:attribute>
							</xsl:when>
							<xsl:otherwise>
								<xsl:attribute name="width">
									<xsl:value-of select="$html.width"/>
								</xsl:attribute>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:when>
					
					<xsl:when test="$scaled.contentwidth != '' and $html.width != ''">
						<xsl:attribute name="width">
							<xsl:value-of select="$html.width"/>
						</xsl:attribute>
					</xsl:when>
					
					<xsl:when test="$scaled.contentdepth != '' and $html.depth != ''">
						<xsl:attribute name="height">
							<xsl:value-of select="$html.depth"/>
						</xsl:attribute>
					</xsl:when>
				</xsl:choose>
			</xsl:when>
		</xsl:choose>
		
		<xsl:choose>
			<xsl:when test="$alt != ''">
				<xsl:attribute name="alt">
					<xsl:value-of select="normalize-space($alt)"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:when test="ancestor::d:screenshot">
				<xsl:attribute name="alt">
					<xsl:value-of select="normalize-space(ancestor::d:screenshot/d:info/d:title)"/>
				</xsl:attribute>
			</xsl:when>
			<xsl:otherwise>
				<xsl:attribute name="alt">image</xsl:attribute>
			</xsl:otherwise>
		</xsl:choose>
		
		<xsl:if test="$longdesc != ''">
			<xsl:attribute name="longdesc">
				<xsl:value-of select="$longdesc"/>
			</xsl:attribute>
		</xsl:if>
		
		<xsl:if test="@align and $viewport = 0">
			<xsl:attribute name="style">
				<xsl:text>text-align: </xsl:text>
				<xsl:choose>
					<xsl:when test="@align = 'center'">middle</xsl:when>
					<xsl:otherwise>
						<xsl:value-of select="@align"/>
					</xsl:otherwise>
				</xsl:choose>
			</xsl:attribute>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>
