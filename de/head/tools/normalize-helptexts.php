#!/usr/bin/php -q
<?php

$dirs = array(
	dirName(__FILE__) .'/../docbook/anhang/applications/',
	dirName(__FILE__) .'/../docbook/anhang/functions/',
	dirName(__FILE__) .'/../docbook/anhang/manager/',
	dirName(__FILE__) .'/../docbook/anhang/agi/',
	dirName(__FILE__) .'/../docbook/anhang/cli/',
);

foreach ($dirs as $dir) {
	$files = glob( $dir.'*-1.*.txt');
	foreach ($files as $file) {
		echo "$file\n";
		
		$txt = trim(@file_get_contents($file),"\n\r");
		$txt = preg_replace('/\x09/S', '        ', $txt);
		$txt = preg_replace('/ +$/mS', '', $txt);
		if (strLen($txt) > 0) $txt.= "\n";
		$fh = @fOpen($file, 'wb');
		@fWrite($fh, $txt, strLen($txt));
		@fClose($fh);
	}
	echo "\n";
}


?>