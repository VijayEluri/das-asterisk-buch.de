
about:
	@ echo ""
	@ echo "Targets:"
	@ echo "  make one       :  Resolve xi:includes"
	@ echo ""
	@ echo "  make clean     :  Clean up"
	@ echo ""


_xmllint:
	@ echo 'Checking xmllint ...'
	@ if [ -z `which xmllint` ]; then \
		echo '############################################################' ;\
		echo '#  xmllint not found.' ;\
		if [ `which aptitude 2>>/dev/null` ]; then \
			echo '#  ( sudo aptitude install libxml2-utils )' ;\
		fi ;\
		echo '############################################################' ;\
		exit 1 ;\
	fi

one: _xmllint
	rm -rf asterisk-buch-komplett
	mkdir -p asterisk-buch-komplett
	
	xmllint --nonet --xinclude --encode UTF-8 docbook/das-asterisk-buch.xml > asterisk-buch-komplett/asterisk-buch-1file.xml
	cat asterisk-buch-komplett/asterisk-buch-1file.xml | sed -r -e 's/fileref="[.\/]*/fileref="/g' > asterisk-buch-komplett/asterisk-buch.xml
	rm asterisk-buch-komplett/asterisk-buch-1file.xml
	
	cp -r docbook/bilder asterisk-buch-komplett/
	rm -rf asterisk-buch-komplett/bilder/.svn* || true
	rm -rf asterisk-buch-komplett/bilder/.cvs* || true
	rm -rf asterisk-buch-komplett/bilder/.git* || true
	
	tar -cvzf asterisk-buch-komplett.tar.gz asterisk-buch-komplett
	zip -r asterisk-buch-komplett.zip asterisk-buch-komplett



.PHONY: about _xmllint one

