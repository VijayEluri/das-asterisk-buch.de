#!/usr/bin/php5
<?php

$dir = "./";
if ($dh = opendir($dir)) {
    while (($file = readdir($dh)) !== false) {
        if (preg_match("/xml$/", $file)) {
            $filename[] = $file;
        }
    }
    closedir($dh);
}

$xy = 0;

foreach ($filename as $value){
    $bak = $value . ".bak";
    copy ($value, $bak);
    $write = fopen ($value, "w");
    $read = fopen ($bak, "r");
    while (!feof($read)) {
        $buffer = fgets($read);
        if (strstr($buffer, '<screen>') or (strstr($buffer, '<programlisting>'))){
            $xy = 1;
        }
        if (strstr($buffer, '</screen>')){
            if (!ereg( '^</screen>', $buffer)){
                $buffer = str_replace('</screen>', 'yyy123yyysw</screen>', $buffer);
            }
            $xy = 0;
        }
        if (strstr($buffer, '</programlisting>')){
            if (!ereg( '^</programlisting>', $buffer)){
                $buffer = str_replace('</programlisting>', 'yyy123yyysw</programlisting>', $buffer);
                }
            $xy = 0;
        }
        if ($xy == 1) {
            $buffer = ereg_replace("\n", "yyy123yyysw\n", $buffer);
        }
        fwrite ($write, $buffer);
    }
    fclose ($write);
    fclose ($read);
    unlink ($bak);
}
