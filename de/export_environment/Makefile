CURDIR = $(shell pwd)
include $(CURDIR)/Makefile.inc

all: validatedocbook
	$(MAKE) pdf 
	$(MAKE) html 
	$(MAKE) htmlsp 
	$(MAKE) epub 

pdf: $(PDFDIR)/Makefile
ifdef VERSION5
	test "0" = "${VALIDATE}" || java -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration  -jar ${DEPENDDIR}/jing/jing.jar ${DEPENDDIR}/docbookxi.rng ${DOCBOOKSRCDIR}/${MAINFILE}
endif
ifdef VERSION4
	test "0" = "${VALIDATE}" || xmllint --nonet --noent --xinclude --postvalid --noout ${DOCBOOKSRCDIR}/${MAINFILE}
endif
	cd ${PDFDIR} && $(MAKE)

html: $(HTMLDIR)/Makefile
ifdef VERSION5
	test "0" = "${VALIDATE}" || java -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration  -jar ${DEPENDDIR}/jing/jing.jar ${DEPENDDIR}/docbookxi.rng ${DOCBOOKSRCDIR}/${MAINFILE}
endif
ifdef VERSION4
	test "0" = "${VALIDATE}" || xmllint --nonet --noent --xinclude --postvalid --noout ${DOCBOOKSRCDIR}/${MAINFILE}
endif
	cd ${HTMLDIR} && $(MAKE) 

htmlsp: $(HTMLSPDIR)/Makefile
ifdef VERSION5
	test "0" = "${VALIDATE}" || java -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration  -jar ${DEPENDDIR}/jing/jing.jar ${DEPENDDIR}/docbookxi.rng ${DOCBOOKSRCDIR}/${MAINFILE}
endif
ifdef VERSION4
	test "0" = "${VALIDATE}" || xmllint --nonet --noent --xinclude --postvalid --noout ${DOCBOOKSRCDIR}/${MAINFILE}
endif
	cd ${HTMLSPDIR} && $(MAKE) 

epub: $(EPUBDIR)/Makefile
ifdef VERSION5
	test "0" = "${VALIDATE}" || java -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration  -jar ${DEPENDDIR}/jing/jing.jar ${DEPENDDIR}/docbookxi.rng ${DOCBOOKSRCDIR}/${MAINFILE}
endif
ifdef VERSION4
	test "0" = "${VALIDATE}" || xmllint --nonet --noent --xinclude --postvalid --noout ${DOCBOOKSRCDIR}/${MAINFILE}
endif
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
ifdef VERSION5
	test "0" = "${VALIDATE}" || java -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration  -jar ${DEPENDDIR}/jing/jing.jar ${DEPENDDIR}/docbookxi.rng ${DOCBOOKSRCDIR}/${MAINFILE}
endif
ifdef VERSION4
	test "0" = "${VALIDATE}" || xmllint --nonet --noent --xinclude --postvalid --noout ${DOCBOOKSRCDIR}/${MAINFILE}
endif
	@echo "****************************************************"

.PHONY: all pdf html htmlsp epub

clean: pdfclean htmlclean epubclean htmlspclean
