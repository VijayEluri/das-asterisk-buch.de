#!/usr/bin/php5 -q
<?php

$bNote = false;
$bScreen = false;

$sAstHelpText = "";

# Die Callback-Funktionen definieren
function startElement( $parser, $name, $attrs )
{
	global $bNote;
	global $bScreen;
	global $sAstHelpText;
	
	if ($name === 'NOTE')
	{
		$bNote = true;
	}
	elseif ($name === 'SCREEN')
	{
		$sAstHelpText = '';
		$bScreen = true;
	}
}

function endElement( $parser, $name )
{
	global $bNote;
	global $bScreen;
	global $sAstHelpText;
	
	if($name === 'NOTE')
	{
		$bNote = false;
	}
	elseif ($name === 'SCREEN')
	{
		# den Text in eine Datei schreiben
		
		# -= Info about application 'AgentLogin' =-
		if (preg_match('/-= Info about application \'(?<appname>\w+)\' =-/', $sAstHelpText, $erg)) {
			
			echo $erg['appname'] ,"\n";
			$fp = fopen( 'applications/'.$erg['appname'].'_1_4.xml' , 'wb');
			
			fwrite($fp, $sAstHelpText, strLen($sAstHelpText));
			
			fclose($fp);
			//echo $sAstHelpText;
			//echo "\n\n\n";
		}
		$bScreen = false;
	}
}

function characterData( $parser, $data )
{
	global $bNote;
	global $bScreen;
	global $sAstHelpText;
	
	if ($bNote && $bScreen)
	{
		$sAstHelpText .= $data;
	}
}


$xml_parser = xml_parser_create();
xml_set_element_handler( $xml_parser, 'startElement', 'endElement' );
xml_set_character_data_handler( $xml_parser, 'characterData' );

$fp = fopen('applications.xml', 'r');

while ($data = fread($fp, 4096))
{
	if (! xml_parse( $xml_parser, $data, feof($fp) ))
	{
		die( sprintf('XML error: %s at line %d',
			xml_error_string( xml_get_error_code( $xml_parser )),
			xml_get_current_line_number( $xml_parser)
			));
	}
}

xml_parser_free( $xml_parser );

?>