#! /usr/bin/php5

<?php

$bNote = false;
$bScreen = false;

$sAstHelpText = "";

# Die callback Funktionen definieren 
function startElement($parser, $name, $attrs) 
{ 
  global $bNote;
  global $bScreen;
  global $sAstHelpText;

  if($name == "NOTE")
    {
    $bNote = true;
    }

  if($name == "SCREEN")
    {
    $sAstHelpText = "";
    $bScreen = true;
    }


} 
function endElement($parser, $name) 
{
  global $bNote;
  global $bScreen;
  global $sAstHelpText;

  if($name == "NOTE")
    {
    $bNote = false;
    } 
  
  if($name == "SCREEN")
    {
    //den Text in ein FILE Schreiben, dass so heist, wie die Applikation.xml

    // -= Info about application 'AgentLogin' =-

    if(preg_match('/-= Info about application \'(?<appname>\w+)\' =-/', $sAstHelpText, $erg))

    echo $erg['appname'] . "\n";
    $fp = fopen("applications/".$erg['appname']."_1_4.xml" , 'w');

    fwrite($fp, $sAstHelpText);

    fclose($fp);
    //echo $sAstHelpText;
    //echo "\n\n\n";

    $bScreen = false;
    }

  
} 
function characterData($parser, $data) 
{ 
  global $bNote;
  global $bScreen;
  global $sAstHelpText;

  if($bNote && $bScreen)
    {
    $sAstHelpText .= $data;
    }
} 
 
 
$xml_parser = xml_parser_create();
xml_set_element_handler($xml_parser, "startElement", "endElement");
xml_set_character_data_handler($xml_parser, "characterData");
 
$fp = fopen("applications.xml", "r");
 
while ($data = fread($fp, 4096)) 
  {
  if (!xml_parse($xml_parser, $data, feof($fp))) 
    { 
    die(sprintf("XML error: %s at line %d", 
                xml_error_string(xml_get_error_code($xml_parser)), 
                xml_get_current_line_number($xml_parser))); 
    } 
  } 
 
xml_parser_free($xml_parser);
?> 