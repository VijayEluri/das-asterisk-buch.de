<?php

$fp = fopen("apps_book_1.4", 'r');

while(!feof($fp))
{
  $line = fgets ( $fp, 255 );
  $erg = array();

  trim($line);
  preg_match('/(?<appname>\w+)/', $line, $erg);

  if(strlen($erg['appname'] ) == 0)
    continue;

  $command = "diff -b -B applications/".$erg['appname']."_helptxt_1_4.xml applications_1_4/".$erg['appname']."_helptxt_1_4.xml 2> /dev/null" ;

  //echo $command . "\n\n";

  $boo = exec($command, $foo, $ret);

  if($ret == 1)
    {
    echo $erg['appname']."\n";
    }

}



?>