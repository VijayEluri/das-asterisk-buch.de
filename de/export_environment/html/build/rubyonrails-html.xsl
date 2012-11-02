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
  <xsl:include href="breadcrumbs.xsl" />
  
  <xsl:param name="generate.legalnotice.link" select="0"/>
  <xsl:param name="generate.revhistory.link" select="0"/>
  <xsl:param name="use.extensions" select="1"/>
  <xsl:param name="tablecolumns.extension" select="0"/>
  
  <xsl:param name="chunk.section.depth" select="1"/>
  <xsl:param name="chunk.first.sections" select="1"/>
  <xsl:param name="section.autolabel.max.depth" select="2"/>
  <xsl:param name="chunk.toc" select="''"/>
  <xsl:param name="chunk.append"/>
  <xsl:param name="chunker.output.quiet" select="0"/>
<!--<xsl:param name="base.dir">html/</xsl:param>-->
  <xsl:param name="use.id.as.filename" select="1"/>
  <xsl:param name="prod.url">http://wintermeyer.de/</xsl:param>
  <xsl:param name="doc.url">http://wintermeyer.de/</xsl:param>
  <xsl:param name="default.image.width" select="'650px'"/>
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

  <xsl:template name="user.head.content">
    <meta name="viewport" content="width=device-width, initial-scale=1.0" />
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
            Copyright © 2010-2012 <a class="twitter-link" rel="me" href="https://twitter.com/wintermeyer" title="Stefan Wintermeyer"><span>Stefan Wintermeyer</span>
            </a>.
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

    <html lang="de">    
      <xsl:call-template name="html.head">
        <xsl:with-param name="prev" select="$prev"/>
        <xsl:with-param name="next" select="$next"/>
      </xsl:call-template>
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      
      <body>
        <div class="navbar navbar-inverse navbar-fixed-top">
          <div class="navbar-inner">
            <div class="container-fluid">
              <a class="brand" href="index.html">Asterisk 1.4 - 1.6</a>
              <div class="nav-collapse collapse">
                <p class="navbar-text pull-right">
                  <a href="http://www.amazon.de/gp/product/3827330335?tag=wwwamoomade-21" class="navbar-link">Buch bei Amazon kaufen</a>
                </p>
              </div><!--/.nav-collapse -->
            </div>
          </div>
        </div>
        
        <div id="container-fluid">
          <div id="row-fluid">
            <div id="adsense-leaderboard" class="span12">
              <script type="text/javascript">
                <xsl:text disable-output-escaping="yes">
<![CDATA[<!--]]>
google_ad_client = "ca-pub-9538764634478220";
/* das-asterisk-buch.de Leaderboard */
google_ad_slot = "2883909891";
google_ad_width = 728;
google_ad_height = 90;
<![CDATA[//-->]]>
               </xsl:text>
              </script>
              <script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js"></script>
            </div>

            <div class="span9">
              <xsl:copy-of select="$content"/>
            </div>

            <div class="span3">

              <div class="well sidebar-nav">
                <xsl:call-template name="breadcrumbs"/>
              </div>

              <div id="adsense-skyscraper">
                <script type="text/javascript">
                  <xsl:text disable-output-escaping="yes">
<![CDATA[<!--]]>
google_ad_client = "ca-pub-9538764634478220";
/* Asterisk 1.4-1.6 wide skyscraper */
google_ad_slot = "9454129820";
google_ad_width = 160;
google_ad_height = 600;
<![CDATA[//-->]]>
                 </xsl:text>
                </script>
                <script type="text/javascript" src="http://pagead2.googlesyndication.com/pagead/show_ads.js"></script>
              </div>

            </div>
          </div>  

          <div id="row-fluid">
            <div class="span12">
              
              <xsl:call-template name="user.footer.content"/>
              
              <xsl:call-template name="footer.navigation">
                <xsl:with-param name="prev" select="$prev"/>
                <xsl:with-param name="next" select="$next"/>
                <xsl:with-param name="nav.context" select="$nav.context"/>
              </xsl:call-template>
              
              <xsl:call-template name="user.footer.navigation"/>
            </div>
          </div>
        </div>
        <xsl:if test="$analyticsincluded = 1">
          <xsl:copy-of select="$analyticsfile/analytics/node()"/>
        </xsl:if>
      </body>
    </html>

    <xsl:value-of select="$chunk.append"/>
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

  <xsl:template name="book.titlepage">
  </xsl:template>

  <xsl:template name="dedication.titlepage">
  </xsl:template> 

</xsl:stylesheet>
