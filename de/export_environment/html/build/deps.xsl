<?xml version='1.0'?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:d="http://docbook.org/ns/docbook" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" exclude-result-prefixes="exsl d" version="1.0">
<xsl:import href="/home/books/DocBook-formated/Das-Asterisk-Buch/de/export_environment/dependencies/docbook-xsl-1.75.2/xhtml-1_1/docbook.xsl"/>
<xsl:import href="/home/books/DocBook-formated/Das-Asterisk-Buch/de/export_environment/dependencies/docbook-xsl-1.75.2/xhtml-1_1/chunkfast.xsl"/>
<xsl:variable name="adfile" select="document('/home/books/DocBook-formated/Das-Asterisk-Buch/de/export_environment/html/build/../..//html/build/ad.xml',/)"/>
<xsl:variable name="analyticsfile" select="document('/home/books/DocBook-formated/Das-Asterisk-Buch/de/export_environment/html/build/../..//html/build/analytics.xml',/)"/>
<xsl:variable name="extrahtmlfile" select="document('/home/books/DocBook-formated/Das-Asterisk-Buch/de/export_environment/html/build/../..//html/build/extrahtml.xml',/)"/>
<xsl:variable name="enableads" select="0"/>
</xsl:stylesheet>
