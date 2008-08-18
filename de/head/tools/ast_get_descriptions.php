#!/usr/bin/php -q
<?php

mb_internal_encoding('UTF-8');
mb_regex_encoding('UTF-8');
mb_regex_set_options('pr');  # default: "pr"
mb_http_output('pass');
mb_language('uni');
mb_substitute_character(0xFFFD);
mb_detect_order('auto');
$tmp = strToLower(trim(@ini_get('mbstring.func_overload')));
if ($tmp >= '1' || $tmp === 'on') {
	echo "mbstring.func_overload must not be enabled in php.ini\n";
	exit(1);
}

$tmp = baseName($argv[0]);
if     (strPos($tmp, 'applications') !== false) $mode = 'a';
elseif (strPos($tmp, 'functions'   ) !== false) $mode = 'f';
elseif (strPos($tmp, 'manager'     ) !== false) $mode = 'm';
else {
	echo "\nERROR. Unknown mode.\n\n";
	exit(1);
}


function _un_terminal_color( $str )
{
	# skip ANSI terminal color escape sequences:
	return preg_replace('/\x1B\[\d+(?:;\d+)*m/S', '', $str);
}

function _xmlent( $str )
{
	return str_replace('\'', '&apos;', htmlSpecialChars( $str, ENT_COMPAT, 'UTF-8' ));
}
//echo _xmlent('  "  &  \'  <  >   ') ,"\n";


exec( 'asterisk -rx '. escapeShellArg('core set verbose 0') .' 1>>/dev/null 2>>/dev/null' );


echo "\n";
$err=0; $out=array();
exec( 'asterisk -rx '. escapeShellArg('core show version'), $out, $err );
if ($err !== 0) {
	echo "\nERROR\n".implode("\n",$out)."\n\n";
	exit(1);
}
$out = _un_terminal_color(implode("\n", $out));
if (! preg_match('/Asterisk ([0-9.\-a-zA-Z]+)/', $out, $m)) {
	echo "\nERROR. Failed to get version.\n\n";
	exit(1);
}
$ast_vers = $m[1];
if (preg_match('/^SVN-branch-/i', $ast_vers, $m)) {
	$ast_vers = subStr($ast_vers, strLen($m[0]));
}
if (preg_match('/^([0-9]+)\.([0-9]+)/', $ast_vers, $m)) {
	$ast_vers = $m[1].'.'.$m[2];
}
echo "ASTERISK VERSION: $ast_vers\n";


switch ($mode) {
	case 'a': $dir = 'applications'; break;
	case 'f': $dir = 'functions'   ; break;
	case 'm': $dir = 'manager'     ; break;
	default : exit(1);
}
$dir.= '-'.$ast_vers.'-'.date('Ymd-His');
echo "DIRECTORY: $dir\n";
$ok = mkdir($dir);
if (! $ok) {
	echo "\nFailed to create \"$dir\" directory.\n\n";
	exit(1);
}

echo "\n";
switch ($mode) {
	case 'a': $rxn = 'core show applications'   ;
	          $rx1 = 'core show application %s' ;  break;
	case 'f': $rxn = 'core show functions'      ;
	          $rx1 = 'core show function %s'    ;  break;
	case 'm': $rxn = 'manager show commands'    ;
	          $rx1 = 'manager show command %s'  ;  break;
	default : exit(1);
}
$err=0; $out=array();
exec( 'asterisk -rx '. escapeShellArg($rxn), $out, $err );
if ($err !== 0) {
	echo "\nERROR\n".implode("\n",$out)."\n\n";
	exit(1);
}
$m = array();
switch ($mode) {
	case 'a': $pat = '/^[ \t]*([A-Z][a-zA-Z0-9_]*)[ \t:]/m'; break;
	case 'f': $pat = '/^[ \t]*([A-Z][A-Z0-9_]+)[ \t:]/m'   ; break;
	case 'm': $pat = '/^[ \t]*([A-Z][a-zA-Z0-9_]*)[ \t:]/m'; break;
	default : exit(1);
}
preg_match_all($pat, _un_terminal_color(implode("\n",$out)), $m);
unset($out);
if (! is_array($m) || count($m) < 1) {
	echo "\nERROR\n\n";
	exit(1);
}
$items = $m[1];
unset($m);
sort($items);

$c = count($items);
$cl = strLen($c);
$cpad = str_pad($c,$cl,' ',STR_PAD_LEFT);
$i = 0;
foreach ($items as $item) {
	++$i;
	echo '(',str_pad($i,$cl,' ',STR_PAD_LEFT),'/',$cpad,')  ', $item ,"\n";
	
	$err=0; $out=array();
	exec( 'asterisk -rx '. escapeShellArg(sPrintF($rx1,$item)), $out, $err );
	if ($err !== 0) {
		echo "\nERROR\n".implode("\n",$out)."\n\n";
		exit(1);
	}
	$out = implode("\n", $out);
	# skip ANSI terminal color escape sequences:
	$out = _un_terminal_color($out);
	# replace tabs:
	$out = preg_replace('/\x09/S', '        ', $out);
	# trim:
	$out = trim($out);
	
	$o = $out ."\n";
	$fh = fOpen( $dir.'/'.$item.'-help.txt', 'wb' );
	if (! $fh) {
		echo "\nERROR. Failed to open file.\n\n";
		exit(1);
	}
	fWrite($fh, $o, strLen($o));
	fClose($fh);
	
	$o = '<'.'?xml version="1.0" encoding="UTF-8"?'.'>'."\n";
	$o.= '<screen>'. _xmlent($out) .'<screen>'."\n";
	$fh = fOpen( $dir.'/'.$item.'-help.xml', 'wb' );
	if (! $fh) {
		echo "\nERROR. Failed to open file.\n\n";
		exit(1);
	}
	fWrite($fh, $o, strLen($o));
	fClose($fh);
}


?>
