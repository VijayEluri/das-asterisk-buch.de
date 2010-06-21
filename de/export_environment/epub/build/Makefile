CURDIR = $(shell pwd)
TOPDIR = $(CURDIR)/../..
include $(TOPDIR)/Makefile.inc
DOCBOOKNSDIR_CLEANED = $(shell cd ${DOCBOOKNSDIR}; pwd | awk -F"$$" {'print $1'})

DOCBOOKXSLPATH :=  ${DOCBOOKNSDIR_CLEANED}/epub/docbook.xsl 

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
	echo "</xsl:stylesheet>" >> deps.xsl

	sed 's/.xsl \"/.xsl\"/' deps.xsl  > tmp.xsl; mv tmp.xsl deps.xsl
	
	$(DOCBOOKNSDIR_CLEANED)/epub/bin/dbtoepub -d -i $(DEPENDDIR)/custom-admons-callouts/ -c $(EPUBDIR)/epub.css -s $(EPUBDIR)/epub.xsl -o $(EXPORTDIR)/document.epub $(DOCBOOKSRCDIR)/index.xml

validate:
	java -jar $(EPUBDIR)/epubcheck/epubcheck-1.0.5.jar $(EXPORTDIR)/document.epub

clean:
	rm -f $(EXPORTDIR)/document.epub deps.xsl
