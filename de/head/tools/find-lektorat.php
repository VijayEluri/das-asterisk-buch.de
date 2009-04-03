#!/usr/bin/php -q
<?php

$docbook_dir = realPath(dirName(__FILE__).'/../docbook');
if ($docbook_dir == '') exit(1);
echo '  ',$docbook_dir,"\n\n\n";

function qsa( $str )
{
	return ($str != '' ? escapeShellArg($str) : '\'\'');
}

$err=0; $out=array();
exec( 'cd '.qsa($docbook_dir).' && LANG=C svn log -v', $out, $err );
if ($err != 0) exit(1);


$files = array();

$commit = '';
foreach ($out as $line) {
	if (subStr($line,0,70) === '----------------------------------------------------------------------') {
		if ($commit != '') {
			$msg = preg_match('/\n\n(.*)/m', $commit, $m) ? $m[1] : '';
			if (preg_match('/lektorat/i', $msg)) {
				$date = preg_match('/200[0-9]-[0-9]{1,2}-[0-9]{1,2}/', $commit, $m) ? $m[0] : '0000-00-00';
				if (preg_match_all('/^   M ([^\n\r]+)/m', $commit, $m)) {
					foreach ($m[1] as $file) {
						if (! array_key_exists($file, $files)) {
							$file = preg_replace('/^\/(?:de|en)\/(?:head|trunk)\/docbook\//', '', $file);
							//$file = preg_replace('/^\/docbook\//', '', $file);
							if (! preg_match('/^\/docbook\//', $file)) {
								$files[$file] = array(
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

kSort($files);
$max_file_len = 0;
foreach ($files as $file => $info) {
	if (strLen($file) > $max_file_len)
		$max_file_len = strLen($file);
}
foreach ($files as $file => $info) {
	echo str_pad($file, $max_file_len, ' '), "\t", $info['date'] , "\t", $info['msg'] ,"\n";
}

