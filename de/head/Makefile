
about:
	@ echo ""
	@ echo "Targets:"
	@ echo "  make one-file  :  Resolve xi:includes"
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

one-file: _xmllint
	xmllint --nonet --xinclude --encode UTF-8 docbook/das-asterisk-buch.xml > das-asterisk-buch-komplett.xml
	tar -cvzf das-asterisk-buch-komplett.xml.tar.gz das-asterisk-buch-komplett.xml



.PHONY: about _xmllint one-file

