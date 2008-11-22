#!/usr/bin/php -q
<?php

$dir = dirName(__FILE__) .'/../docbook/anhang/applications/';


$files = glob( $dir.'*-1.*.txt');
print_r($files);
foreach ($files as $file) {
	echo "$file\n";
	
	$txt = rTrim(@file_get_contents($file),"\n\r");
	if (strLen($txt) > 0) $txt.= "\n";
	$fh = @fOpen($file, 'wb');
	@fWrite($fh, $txt, strLen($txt));
	@fClose($fh);
}
echo "\n";


?>