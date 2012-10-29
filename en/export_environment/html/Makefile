# Makefile um das Buch zu bauen.
# Autor: Philipp Kempgen <philipp.kempgen@amooma.de>
# Copyright 2010, Amooma GmbH


docbook_sources = $(wildcard docbook/*.xml)
docbook_entry_file = docbook/index.xml


xmllint = $(shell which xmllint)
xsltproc = $(shell which xsltproc)
#xmlcatalog = $(shell which xmlcatalog)
tidy = $(shell which tidy)
docbook_xsl_images = /usr/share/xml/docbook/stylesheet/docbook-xsl-ns/images
docbook_version = $(shell grep -Eoe '\bversion=["'\'']5\.[0-9.]+' $(docbook_entry_file) 2>>/dev/null | cut -d = -f 2 | grep -Eoe '5\.[0-9.]+' | head -n 1)


help:
	@ echo ""
	@ echo " ## Targets:"
	@ echo ""
	@ echo " make html ....................: Generate HTML pages"
	@ echo " make clean ...................: Remove all generated files"
	@ echo ""
	@ echo " ## More targets:"
	@ echo ""
	@ echo " make validate ................: Validate DocBook sources"
	@ echo "                                 (always before commit!)"
	@# echo " make validate-html-chunk-xsl .: Validate the output of"
	@# echo "                                 html-chunk-xsl"


# We use a tmp directory for various make timestamps and
# intermediate files in order not to clutter the main directory.
# If a target needs this directory it has to depend on
# tmp/_tmp_dir-stamp.
# The downside of the tmp directory is that whenever we create
# a file in tmp and thus modify the directory's mtime we have
# to reset the directory's mtime to the time when it was created:
# touch -d "`cat tmp/_tmp_dir-stamp`" tmp

tmp:
	mkdir -p tmp
	sleep 1

tmp/_tmp_dir-stamp: tmp
	@ date '+%Y-%m-%d %H:%M:00 %z' > tmp/_tmp_dir-stamp
	@ touch -d "`cat tmp/_tmp_dir-stamp`" tmp


tmp/_have-xmllint-stamp: tmp/_tmp_dir-stamp
	@ echo "Checking for xmllint ..."
	@ if [ -z "$(xmllint)" ]; then \
		echo "\033[91;40m"; \
		echo '############################################################'; \
		echo '#  xmllint not found.                                      #'; \
		echo '#  Please install XML/DocBook Utils.                       #'; \
		if [ `which aptitude 2>>/dev/null` ]; then \
			echo '#  ( sudo aptitude install libxml2-utils docbook-xml docbook5-xml docbook-xsl docbook-xsl-ns docbook-utils xsltproc )'; \
		fi; \
		echo '############################################################'; \
		echo "\033[0m"; \
		exit 1; \
	fi
	@ date > tmp/_have-xmllint-stamp
	@ touch -d "`cat tmp/_tmp_dir-stamp`" tmp


tmp/_have-xsltproc-stamp: tmp/_tmp_dir-stamp
	@ echo "Checking for xsltproc ..."
	@ if [ -z "$(xsltproc)" ]; then \
		echo "\033[91;40m"; \
		echo '############################################################'; \
		echo '#  xsltproc not found.                                     #'; \
		echo '#  Please install xsltproc.                                #'; \
		if [ `which aptitude 2>>/dev/null` ]; then \
			echo '#  ( sudo aptitude install xsltproc )'; \
		fi; \
		echo '############################################################'; \
		echo "\033[0m"; \
                exit 1; \
	fi
	@ date > tmp/_have-xsltproc-stamp
	@ touch -d "`cat tmp/_tmp_dir-stamp`" tmp


tmp/_have-docbook5rng-stamp: tmp/_tmp_dir-stamp
	@ echo "DocBook version of entry file \"$(docbook_entry_file)\" is: $(docbook_version)"
	@ if [ -z "$(docbook_version)" ]; then \
		echo "\033[91;40m"; \
		echo '############################################################'; \
		echo '#  Could not find DocBook version in entry file            #'; \
		echo '#  "$(docbook_entry_file)".'; \
		echo '############################################################'; \
		echo "\033[0m"; \
		exit 1; \
	fi
	@ echo "Checking for DocBook RelaxNG schema ..."
	@ if [ ! -e "/usr/share/xml/docbook/schema/rng/$(docbook_version)/docbook.rng" ]; then \
		echo "\033[91;40m"; \
		echo '############################################################'; \
		echo '#  "/usr/share/xml/docbook/schema/rng/$(docbook_version)/docbook.rng"     #'; \
		echo '#  not found.                                              #'; \
		echo '#  Please install DocBook $(docbook_version) RelaxNG schema.              #'; \
		if [ `which aptitude 2>>/dev/null` ]; then \
			echo '#  ( sudo aptitude install docbook5-xml )'; \
		fi; \
		echo '############################################################'; \
		echo "\033[0m"; \
		exit 1; \
	fi
	@ date > tmp/_have-docbook5rng-stamp
	@ touch -d "`cat tmp/_tmp_dir-stamp`" tmp


tmp/_have-docbook-ns-xsl-xhtml-chunk-stamp: tmp/_tmp_dir-stamp
	@ echo "Checking for DocBook 5 XSL stylesheets (to XHTML, chunked) ..."
	@ if [ ! -e "/usr/share/xml/docbook/stylesheet/docbook-xsl-ns/xhtml/chunk.xsl" ]; then \
		echo "\033[91;40m"; \
                echo '############################################################'; \
		echo '#  "/usr/share/xml/docbook/stylesheet/docbook-xsl-ns/xhtml/chunk.xsl"'; \
		echo '#  not found.                                              #'; \
		echo '#  Please install DocBook NS XSL stylesheets.              #'; \
		if [ `which aptitude 2>>/dev/null` ]; then \
			echo '#  ( sudo aptitude install docbook-xsl-ns )'; \
		fi; \
		echo '############################################################'; \
                echo "\033[0m"; \
                exit 1; \
	fi
	@ date > tmp/_have-docbook-ns-xsl-xhtml-chunk-stamp
	@ touch -d "`cat tmp/_tmp_dir-stamp`" tmp


tmp/_have-tidy-stamp: tmp/_tmp_dir-stamp
	@ echo "Checking for tidy ..."
	@ if [ -z "$(tidy)" ]; then \
		echo "\033[91;40m"; \
		echo '############################################################'; \
		echo '#  tidy not found.                                         #'; \
		echo '#  Please install tidy.                                    #'; \
		if [ `which aptitude 2>>/dev/null` ]; then \
			echo '#  ( sudo aptitude install tidy )'; \
		fi; \
		echo '############################################################'; \
                echo "\033[0m"; \
                exit 1; \
	fi
	@ date > tmp/_have-tidy-stamp
	@ touch -d "`cat tmp/_tmp_dir-stamp`" tmp


tmp/_docbook-valid-stamp: $(docbook_sources) tmp/_have-xmllint-stamp tmp/_have-docbook5rng-stamp
	@ echo "\033[92;40m"
	@ echo '############################################################';
	@ echo '#  Validating DocBook sources ...                          #';
	@ echo '############################################################';
	@ echo "\033[0m"
	$(xmllint) --xinclude --noout \
		--relaxng "/usr/share/xml/docbook/schema/rng/$(docbook_version)/docbook.rng" \
		$(docbook_entry_file)
	@ echo "\033[92;40m"
	@ echo '############################################################';
	@ echo '#  DocBook sources are valid.                              #';
	@ echo '############################################################';
	@ echo "\033[0m"
	@ date > tmp/_docbook-valid-stamp
	@ touch -d "`cat tmp/_tmp_dir-stamp`" tmp


validate: tmp/_docbook-valid-stamp


html: html-chunk-xsl

html-chunk-xsl: html-chunk-xsl/index.html

html-chunk-xsl/index.html: $(docbook_entry_file) tmp/_docbook-valid-stamp xsl/docbook-html-chunk.xsl tmp/_have-xsltproc-stamp tmp/_have-docbook-ns-xsl-xhtml-chunk-stamp tmp/_have-tidy-stamp
	@ echo "\033[92;40m"
	@ echo '############################################################';
	@ echo '#  Making (X)HTML (chunk, XSLT) ...                        #';
	@ echo '############################################################';
	@ echo "\033[0m"
	
	@ echo "Transforming to HTML ..."
	mkdir -p html-chunk-xsl
	$(xsltproc) \
		--xinclude \
		--novalid \
		--stringparam 'current.docid' 'foo' \
		-o "html-chunk-xsl/" \
		"xsl/docbook-html-chunk.xsl" \
		"$(docbook_entry_file)"
	mkdir -p html-chunk-xsl/img
	@ touch -d "`cat tmp/_tmp_dir-stamp`" tmp
	@ echo "\033[92;40m"
	@ echo '############################################################';
	@ echo '#  (X)HTML (chunk, XSLT) done.                             #';
	@ echo '############################################################';
	@ echo "\033[0m"
	
	@ echo "Tidying HTML ..."
	for html_file in `ls html-chunk-xsl/*.html`; do \
		echo "Tidying `basename $$html_file` ..." ;\
		$(tidy) \
			--add-xml-decl no --assume-xml-procins yes --doctype auto \
			--input-xml no --output-xhtml yes \
			--join-classes no --logical-emphasis no --merge-divs no --merge-spans no \
			--ncr yes --numeric-entities no \
			--quote-marks yes --quote-nbsp yes \
			--show-errors 100 --show-warnings no \
			--indent-spaces 2 --tab-size 2 --vertical-space no \
			--markup yes --sort-attributes none \
			--wrap 180 --wrap-attributes no \
			--wrap-asp no --wrap-php no --wrap-script-literals no --wrap-sections no \
			--char-encoding utf8 --input-encoding utf8 --output-encoding utf8 --output-bom no \
			--tidy-mark no \
			-quiet -asxhtml -indent -access 0 \
			--indent auto \
			-output $$html_file.tidied \
			$$html_file \
			; e=$$? ; [ $$e = 0 -o $$e = 1 ] || exit 1 ;\
		mv $$html_file.tidied $$html_file ;\
	done
	@ echo "\033[92;40m"
	@ echo '############################################################';
	@ echo '#  (X)HTML (chunk, tidy) done.                             #';
	@ echo '############################################################';
	@ echo "\033[0m"
	
	@ echo "Copying CSS stylesheet ..."
	@ if [ -d "css/." ]; then \
		cp -rLT --preserve=timestamps --strip-trailing-slashes \
			"css" "html-chunk-xsl/css" ;\
	fi
	
	@ echo "Copying DocBook images ..."
	@ if [ -e "$(docbook_xsl_images)" ]; then \
		cp -rLT --preserve=timestamps --strip-trailing-slashes \
			"$(docbook_xsl_images)" "html-chunk-xsl/dbkimg" ;\
	else \
		echo "Did not find DocBook images at" ;\
		echo "\"$(docbook_xsl_images)\"!" ;\
	fi
	
	@ echo "\033[92;40m"
	@ echo '############################################################';
	@ echo '#  (X)HTML (chunk) done.                                   #';
	@ echo '############################################################';
	@ echo "\033[0m"


clean:
	rm -rf tmp || true
	rm -rf html-chunk-xsl/* || true


.PHONY: help html-chunk-xsl html


