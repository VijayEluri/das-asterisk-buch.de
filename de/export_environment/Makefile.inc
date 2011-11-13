ENVDIR := $(dir $(lastword $(MAKEFILE_LIST)))
DOCBOOKSRCDIR := $(ENVDIR)/../docbook
PDFDIR := $(ENVDIR)/pdf/build
HTMLDIR := $(ENVDIR)/html/build
EPUBDIR := $(ENVDIR)/epub/build
HTMLSPDIR := $(ENVDIR)/html-single-page/build
DEPENDDIR := $(ENVDIR)/dependencies
EXPORTDIR := $(ENVDIR)/export
#MAINFILE := index.xml
MAINFILE := das-asterisk-buch.xml
IMAGEDIR := bilder
ENABLEADS := 0
STYLESFILE := default.css
VALIDATE := 1

VERSION4 := $(shell grep -A10 '<!DOCTYPE' ${DOCBOOKSRCDIR}/${MAINFILE} | tr -d 'AEFGHIJLMNPQRSUWXYZaefghijlmnpqrsuwxyz' | tr '/' '\n' | grep DTD | tr -d 'DTDocBookXML V\n')

ifdef VERSION4
VERSION := $(shell echo ${VERSION4}\<5.0 | bc)
endif

ifeq ("$(VERSION)","1")
DOCBOOKNSDIR := $(ENVDIR)/dependencies/docbook-xsl-1.75.2/
VERSION5 := 
VERSION := 4
else
VERSION5 := $(shell grep -A15 -e '<book' -e '<article' ${DOCBOOKSRCDIR}/${MAINFILE} | tr ' ' '\n' | grep version | tr -d 'version="\n')
endif

ifdef VERSION5
VERSION := $(shell echo ${VERSION5}\>=5.0 | bc)
endif

ifeq ("$(VERSION)","1")
DOCBOOKNSDIR := $(ENVDIR)/dependencies/docbook-xsl-ns-1.75.2/
VERSION4 := 
VERSION := 5
endif

ifdef V
  Q :=
else
  Q := @
endif

