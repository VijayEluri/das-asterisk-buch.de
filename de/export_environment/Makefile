CURDIR = $(shell pwd)
include $(CURDIR)/Makefile.inc
VALIDATE = 1

all: validatedocbook
	$(MAKE) pdf VALIDATE=0
	$(MAKE) html VALIDATE=0
	$(MAKE) htmlsp VALIDATE=0
	$(MAKE) epub VALIDATE=0

pdf: $(PDFDIR)/Makefile
	test "0" = "${VALIDATE}" || java -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration  -jar ${DEPENDDIR}/jing/jing.jar ${DEPENDDIR}/docbookxi.rng ${DOCBOOKSRCDIR}/index.xml 
	cd ${PDFDIR} && $(MAKE)

html: $(HTMLDIR)/Makefile
	test "0" = "${VALIDATE}" || java -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration  -jar ${DEPENDDIR}/jing/jing.jar ${DEPENDDIR}/docbookxi.rng ${DOCBOOKSRCDIR}/index.xml 
	cd ${HTMLDIR} && $(MAKE) 

htmlsp: $(HTMLSPDIR)/Makefile
	test "0" = "${VALIDATE}" || java -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration  -jar ${DEPENDDIR}/jing/jing.jar ${DEPENDDIR}/docbookxi.rng ${DOCBOOKSRCDIR}/index.xml 
	cd ${HTMLSPDIR} && $(MAKE) 

epub: $(EPUBDIR)/Makefile
	test "0" = "${VALIDATE}" || java -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration  -jar ${DEPENDDIR}/jing/jing.jar ${DEPENDDIR}/docbookxi.rng ${DOCBOOKSRCDIR}/index.xml 
	cd ${EPUBDIR} && $(MAKE) 

pdfclean: $(PDFDIR)/Makefile
	cd ${PDFDIR} && $(MAKE) clean

htmlclean: $(HTMLDIR)/Makefile
	cd ${HTMLDIR} && $(MAKE) clean

htmlspclean: $(HTMLSPDIR)/Makefile
	cd ${HTMLSPDIR} && $(MAKE) clean

epubclean: $(EPUBDIR)/Makefile
	cd ${EPUBDIR} && $(MAKE) clean

validatedocbook:
	@echo "**************** Validating DocBook ****************"
	java -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration  -jar ${DEPENDDIR}/jing/jing.jar ${DEPENDDIR}/docbookxi.rng ${DOCBOOKSRCDIR}/index.xml
	@echo "****************************************************"

.PHONY: all pdf html htmlsp epub

clean: pdfclean htmlclean epubclean htmlspclean
