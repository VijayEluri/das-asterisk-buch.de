<?php

$xml = simplexml_load_file('applications.xml');

for($i=0; $i<count($xml->section); $i++)

{
  $sAstHelpText = $xml->section[$i]->note->formalpara[0]->para->screen[0];
  if(strlen($sAstHelpText) == 0)
    continue;

  if(preg_match('/-= Info about application \'(?<appname>\w+)\' =-/', $sAstHelpText, $erg))

  $fp2 = fopen("applications/".$erg['appname']."_helptxt_1_4.xml" , 'w');
  fwrite($fp2, $sAstHelpText);
  fclose($fp2);

  $sAstHelpText = $xml->section[$i]->note->formalpara[1]->para->screen[0];
  $fp3 = fopen("applications/".$erg['appname']."_helptxt_diff_1_2.xml" , 'w');
  fwrite($fp3, $sAstHelpText);
  fclose($fp3);


  //das xml-include an die screen-stellen setzen
  $xml->section[$i]->note->formalpara[0]->para->screen = "";
  $xml->section[$i]->note->formalpara[1]->para->screen = "";
  
  $xml->section[$i]->note->formalpara[0]->para->screen->addChild( 'xiinc');
  $xml->section[$i]->note->formalpara[1]->para->screen->addChild( 'xiinc');
  

  $xml->section[$i]->note->formalpara[0]->para->screen->xiinc->addAttribute("href",
                            "applications/".$erg['appname']."_helptxt_1_4.xml");

  $xml->section[$i]->note->formalpara[0]->para->screen->xiinc->addAttribute("parse", "text");

  $xml->section[$i]->note->formalpara[0]->para->screen->xiinc->addAttribute("xmlns:xmlns:xi",
                                                   "http://www.w3.org/2001/XInclude");

  $xml->section[$i]->note->formalpara[1]->para->screen->xiinc->addAttribute("href",
                                  "applications/".$erg['appname']."_helptxt_diff_1_2.xml");

  $xml->section[$i]->note->formalpara[1]->para->screen->xiinc->addAttribute("parse", "text");

  $xml->section[$i]->note->formalpara[1]->para->screen->xiinc->addAttribute("xmlns:xmlns:xi",
                                                    "http://www.w3.org/2001/XInclude");


  $xmlcode = $xml->section[$i]->note->formalpara[0]->asXML();
  $xmlcode .= $xml->section[$i]->note->formalpara[1]->asXML();

  $fp1 = fopen("applications/".$erg['appname'].".xml" , 'w');
  fwrite($fp1, "<?xml version=\"1.0\" encoding=\"ISO-8859-1\"?>\n<foo>\n");
  fwrite($fp1, $xmlcode);
  fwrite($fp1, "\n</foo>");
  fclose($fp1);




  unset($xml->section[$i]->note->formalpara);
  
  $sAstHelpText = "";

  $xml->section[$i]->note->addChild( 'xiinc');
  
  $xml->section[$i]->note->xiinc->addAttribute("href", "applications/".$erg['appname'].".xml");
  $xml->section[$i]->note->xiinc->addAttribute("parse", "xml");
  $xml->section[$i]->note->xiinc->addAttribute("xmlns:xmlns:xi","http://www.w3.org/2001/XInclude");


}

$xml->asXML("out.xml");

//quick and dirty: xiinc in xi:include umbenennen
system("sed -i 's/xiinc/xi:include/g' out.xml");
system("cd applications && find . -name \"*.xml\" -exec sed -i 's/xiinc/xi:include/g' {} \;");


?>
