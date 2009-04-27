#!/usr/bin/php -q
<?php

$docbook_dir = realPath(dirName(__FILE__).'/../docbook');
if ($docbook_dir == '') exit(1);
echo '  ',$docbook_dir,"\n\n\n";

function qsa( $str )
{
	return ($str != '' ? escapeShellArg($str) : '\'\'');
}


$files_all = array();
$err=0; $out=array();
exec( 'cd '.qsa($docbook_dir).' && find '.qsa($docbook_dir).' -type f | grep -v '.qsa('\\.svn'), $out, $err );
if ($err != 0) exit(1);
foreach ($out as $file) {
	if (subStr($file,0,strLen($docbook_dir)) === $docbook_dir) {
		$file = subStr($file, strLen($docbook_dir));
	}
	if (subStr($file,0,1) === '/') {
		$file = subStr($file,1);
	}
	if (strPos($file,'-help/') !== false) {
		continue;
	}
	if (strPos($file,'-help.xml') !== false) {
		continue;
	}
	if (preg_match('/\\.(?:txt|png|jpg|jpeg|gif)$/', $file)) {
		continue;
	}
	$files_all[] = $file;
}
sort($files_all);
$max_file_len = 0;
foreach ($files_all as $file) {
	if (strLen($file) > $max_file_len)
		$max_file_len = strLen($file);
}


$err=0; $out=array();
exec( 'cd '.qsa($docbook_dir).' && LANG=C svn log -v', $out, $err );
if ($err != 0) exit(1);


$files_lektorat = array();

$commit = '';
foreach ($out as $line) {
	if (subStr($line,0,70) === '----------------------------------------------------------------------') {
		if ($commit != '') {
			$msg = preg_match('/\n\n(.*)/m', $commit, $m) ? $m[1] : '';
			if (preg_match('/lektorat/i', $msg)) {
				$date = preg_match('/200[0-9]-[0-9]{1,2}-[0-9]{1,2}/', $commit, $m) ? $m[0] : '0000-00-00';
				if (preg_match_all('/^   M ([^\n\r]+)/m', $commit, $m)) {
					foreach ($m[1] as $file) {
						if (! array_key_exists($file, $files_lektorat)) {
							$file = preg_replace('/^\/(?:de|en)\/(?:head|trunk)\/docbook\//', '', $file);
							//$file = preg_replace('/^\/docbook\//', '', $file);
							if (! preg_match('/^\/docbook\//', $file)) {
								$files_lektorat[$file] = array(
									'msg'  => $msg,
									'date' => $date
								);
							}
						}
					}
				}
			}
		}
		
		$commit = '';
	} else {
		$commit.= $line."\n";
	}
}

kSort($files_lektorat);
/*
foreach ($files_lektorat as $file => $info) {
	echo str_pad($file, $max_file_len, ' '), "\t", $info['date'] , "\t", $info['msg'] ,"\n";
}
*/
foreach ($files_all as $file) {
	echo str_pad($file, $max_file_len, ' ') ,"\t";
	if (array_key_exists($file, $files_lektorat)) {
		echo '[x]' ,"\t";
		echo $files_lektorat[$file]['date'] ,"\t";
		echo $files_lektorat[$file]['msg'];
	} else {
		echo '[ ]' ,"\t";
		echo '          ' ,"\t";
		echo '##### TODO';
	}
	echo "\n";
}

