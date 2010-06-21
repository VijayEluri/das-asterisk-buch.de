CURDIR = $(shell pwd)
TOPDIR = $(CURDIR)/../..
include $(TOPDIR)/Makefile.inc
DOCBOOKNSDIR_CLEANED = $(shell cd ${DOCBOOKNSDIR}; pwd | awk -F"$$" {'print $1'})

DOCBOOKXSLPATH :=  ${DOCBOOKNSDIR_CLEANED}/fo/docbook.xsl 
GRAPHICSXSLPATH := ${DOCBOOKNSDIR_CLEANED}/fo/graphics.xsl 

all: document.pdf
       
document.pdf: $(EXPORTDIR)/document.fo
	fop -c font-config.xml -fo $(EXPORTDIR)/document.fo -pdf $(EXPORTDIR)/document.pdf
       
$(EXPORTDIR)/document.fo: $(DOCBOOKSRCDIR)/index.xml
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
	echo "<xsl:import href=\"${GRAPHICSXSLPATH}\"/>" >> deps.xsl
	echo "</xsl:stylesheet>" >> deps.xsl

	sed 's/.xsl \"/.xsl\"/' deps.xsl  > tmp.xsl; mv tmp.xsl deps.xsl

	xsltproc --stringparam img.src.path $(DOCBOOKSRCDIR)/ --stringparam admon.graphics.path ${DEPENDDIR}/custom-admons-callouts/ --stringparam callout.graphics.path ${DEPENDDIR}/custom-admons-callouts/ -o $(EXPORTDIR)/document.fo --xinclude ${PDFDIR}/rubyonrails-pdf.xsl $(DOCBOOKSRCDIR)/index.xml

clean:
	rm -f $(EXPORTDIR)/document.fo $(EXPORTDIR)/document.pdf deps.xsl
