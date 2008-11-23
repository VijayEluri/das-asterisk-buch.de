#!/usr/bin/php -q
<?php

function fullDeTab( $text, $tabstop=8 )
{
	$text = str_replace(
		array("\r\n", "\r"),
		array("\n"  , "\n"),
		$text);
	$lines = explode("\n", $text);
	$text = '';
	foreach ($lines as $line) {
		$pos = 0;
		while (($pos = mb_strPos($line, "\t", $pos, 'UTF-8')) !== false) {
			# "....|..\t"
			# "....|....|"
			# spaces needed to next tabstop:
			$sp = ceil(($pos+1) / $tabstop) * $tabstop - $pos;
			$line = subStr($line,0,$pos) . str_repeat(' ',$sp) . subStr($line,$pos+1);
		}
		$text.= $line ."\n";
	}
	return $text;
}

/*
$texts = array(
"
  -= Info about application 'SendImage' =- 
[Description]
The option string may contain the following character:
	'j' -- jump to priority n+101 if the channel doesn't support image transport
This application sets the following channel variable upon completion:
	SENDIMAGESTATUS		The status is the result of the attempt as a text string, one of
		OK | NOSUPPORT 
",
"
  -= Info about application 'TrySystem' =- 
[Description]
  TrySystem(command): Executes a command  by  using  system().
on any situation.
Result of execution is returned in the SYSTEMSTATUS channel variable:
  FAILURE	Could not execute the specified command
  SUCCESS	Specified command successfully executed
  APPERROR	Specified command successfully executed, but returned error code

 	........x
  	......	x
   	........	y
        .........	y
",
);

foreach ($texts as $text) {
	echo ($text);
	echo fullDeTab( $text, 8 );
}
echo "\n\n";
exit;
*/



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


@exec( 'asterisk -rx '. escapeShellArg('set verbose 0') .' 1>>/dev/null 2>>/dev/null' );
@exec( 'asterisk -rx '. escapeShellArg('core set verbose 0') .' 1>>/dev/null 2>>/dev/null' );


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


$dir = dirName(__FILE__).'/';
switch ($mode) {
	case 'a': $dir.= 'applications'; break;
	case 'f': $dir.= 'functions'   ; break;
	case 'm': $dir.= 'manager'     ; break;
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
if ('x'.$ast_vers <= 'x1.4') {
	if (subStr($rxn,0,5) === 'core ') $rxn = subStr($rxn,5);
	if (subStr($rx1,0,5) === 'core ') $rx1 = subStr($rx1,5);
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
	/*
	for ($ti=5; $ti>=1; --$ti)
		$out = preg_replace('/^\x09{'.$ti.'}/mS', str_repeat(' ',8*$ti), $out);
	$out = preg_replace('/\x09/S', str_repeat(' ',4), $out);
	*/
	$out = fullDeTab($out, 8);
	
	# trim:
	$out = trim($out,"\n\r\0");
	$out = preg_replace('/ +$/mS', '', $out);
	
	$fileb = $dir.'/'.strToLower($item).'-help-'.$ast_vers;
	
	$o = $out ."\n";
	$fh = fOpen( $fileb.'.txt', 'wb' );
	if (! $fh) {
		echo "\nERROR. Failed to open file.\n\n";
		exit(1);
	}
	fWrite($fh, $o, strLen($o));
	fClose($fh);
	
	/*
	$o = '<'.'?xml version="1.0" encoding="UTF-8"?'.'>'."\n";
	$o.= '<screen>'. _xmlent($out) .'<screen>'."\n";
	$fh = fOpen( $fileb.'.xml', 'wb' );
	if (! $fh) {
		echo "\nERROR. Failed to open file.\n\n";
		exit(1);
	}
	fWrite($fh, $o, strLen($o));
	fClose($fh);
	*/
}


?>
