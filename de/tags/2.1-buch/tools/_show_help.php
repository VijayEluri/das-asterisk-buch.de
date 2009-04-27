<?php


$fp = fopen("ast16_apps", 'r');


while(!feof($fp))
{
  $line = fgets ( $fp, 255 );

  $erg = array();

  trim($line);

  preg_match('/(?<appname>\w+): (?<discription>\w+)/', $line, $erg);
  

  echo $erg['appname']."\n";


  $command = "asterisk -rx \"core show application " . $erg['appname'] ."\" >> /root/applications/"
   . $erg['appname'] . "_helptxt_1_6.xml";

  system($command);


}

fclose ( $fp );



?>