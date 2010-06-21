CURDIR = $(shell pwd)
TOPDIR = $(CURDIR)/../..
include $(TOPDIR)/Makefile.inc
DOCBOOKNSDIR_CLEANED = $(shell cd ${DOCBOOKNSDIR}; pwd | awk -F"$$" {'print $1'})

DOCBOOKXSLPATH :=  ${DOCBOOKNSDIR_CLEANED}/xhtml/docbook.xsl
TITLEPAGEXSLPATH := ${DOCBOOKNSDIR_CLEANED}/xhtml/titlepage.xsl
 
all:        
	rm -f deps.xsl

	echo "<?xml version='1.0'?>" >> deps.xsl
	echo "<xsl:stylesheet \
	xmlns:xsl=\"http://www.w3.org/1999/XSL/Transform\" \
	xmlns:fo=\"http://www.w3.org/1999/XSL/Format\" \
	xmlns:d=\"http://docbook.org/ns/docbook\" \
	xmlns:exsl=\"http://exslt.org/common\" \
	extension-element-prefixes=\"exsl\" \
	exclude-result-prefixes=\"exsl d\" \
	version=\"1.0\">" >> deps.xsl
	echo "<xsl:import href=\"${DOCBOOKXSLPATH}\"/>" >> deps.xsl
	echo "<xsl:import href=\"${TITLEPAGEXSLPATH}\"/>" >> deps.xsl
	echo "</xsl:stylesheet>" >> deps.xsl

	sed 's/.xsl \"/.xsl\"/' deps.xsl  > tmp.xsl; mv tmp.xsl deps.xsl

	mkdir -p $(EXPORTDIR)/html-single-page
	#cp $(HTMLDIR)/default.css $(HTMLDIR)/common.css $(EXPORTDIR)/html-single-page
	cp -R ${DEPENDDIR}/custom-admons-callouts/ $(EXPORTDIR)/html-single-page
	cp -R ${DOCBOOKSRCDIR}/screenshots $(EXPORTDIR)/html-single-page
	xsltproc -o $(EXPORTDIR)/html-single-page/index.html --stringparam admon.graphics.path ${DEPENDDIR}/custom-admons-callouts/ --stringparam callout.graphics.path ${DEPENDDIR}/custom-admons-callouts/ --stringparam adincluded 0 --xinclude $(HTMLSPDIR)/html-single.xsl $(DOCBOOKSRCDIR)/index.xml; \
	
clean:
	rm -rf $(EXPORTDIR)/html-single-page deps.xsl
