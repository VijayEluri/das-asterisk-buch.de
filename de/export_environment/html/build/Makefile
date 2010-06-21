CURDIR = $(shell pwd)
TOPDIR = $(CURDIR)/../..
include $(TOPDIR)/Makefile.inc
DOCBOOKNSDIR_CLEANED = $(shell cd ${DOCBOOKNSDIR}; pwd | awk -F"$$" {'print $1'})

DOCBOOKXSLPATH :=  ${DOCBOOKNSDIR_CLEANED}/xhtml-1_1/docbook.xsl
CHUNKXSLPATH := ${DOCBOOKNSDIR_CLEANED}/xhtml-1_1/chunk.xsl
EXTRAPARAMS +=  --stringparam base.dir $(EXPORTDIR)/html/ --stringparam admon.graphics.path ./custom-admons-callouts/ --stringparam callout.graphics.path ./custom-admons-callouts/callouts/ 

ifneq ("$(wildcard $(HTMLDIR)/ad.xml)","")
ADS = 1
EXTRAPARAMS +=  --stringparam adincluded 1
else
ADS = 0
EXTRAPARAMS +=  --stringparam adincluded 0
endif

ifneq ("$(wildcard $(HTMLDIR)/analytics.xml)","")
ANALYTICS = 1
EXTRAPARAMS +=  --stringparam analyticsincluded 1
else
ANALYTICS = 0
EXTRAPARAMS +=  --stringparam analyticsincluded 0
endif
 

ifneq ("$(wildcard $(HTMLDIR)/extrahtml.xml)","")
EXTRAHTML = 1
EXTRAPARAMS +=  --stringparam extrahtml 1
else
EXTRAHTML = 0
EXTRAPARAMS +=  --stringparam extrahtml 0
endif

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
	echo "<xsl:import href=\"${CHUNKXSLPATH}\"/>" >> deps.xsl
	test "${ADS}" = "0" || echo "<xsl:variable name=\"adfile\" select=\"document('${HTMLDIR}/ad.xml',/)\"/>" >> deps.xsl
	test "${ANALYTICS}" = "0" || echo "<xsl:variable name=\"analyticsfile\" select=\"document('${HTMLDIR}/analytics.xml',/)\"/>" >> deps.xsl
	test "${EXTRAHTML}" = "0" || echo "<xsl:variable name=\"extrahtmlfile\" select=\"document('${HTMLDIR}/extrahtml.xml',/)\"/>" >> deps.xsl
	echo "</xsl:stylesheet>" >> deps.xsl

	sed 's/.xsl \"/.xsl\"/' deps.xsl  > tmp.xsl; mv tmp.xsl deps.xsl

	mkdir -p $(EXPORTDIR)/html
	cp $(HTMLDIR)/default.css $(HTMLDIR)/common.css $(EXPORTDIR)/html
	cp -R ${DEPENDDIR}/custom-admons-callouts/ $(EXPORTDIR)/html
	cp -R ${DOCBOOKSRCDIR}/screenshots $(EXPORTDIR)/html

	xsltproc $(EXTRAPARAMS) --xinclude $(HTMLDIR)/rubyonrails-html.xsl $(DOCBOOKSRCDIR)/index.xml; \
	
clean:
	rm -rf $(EXPORTDIR)/html deps.xsl
