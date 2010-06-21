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


/*
$tmp = baseName($argv[0]);
if     (strPos($tmp, 'applications') !== false) $mode = 'app';
elseif (strPos($tmp, 'functions'   ) !== false) $mode = 'fnc';
elseif (strPos($tmp, 'manager'     ) !== false) $mode = 'mgr';
elseif (strPos($tmp, 'agi'         ) !== false) $mode = 'agi';
elseif (strPos($tmp, 'cli'         ) !== false) $mode = 'cli';
else {
	echo "\nERROR. Unknown mode.\n\n";
	exit(1);
}
*/
$tmp = baseName($argv[0]);
$usage = <<<HEREDOCEND
Usage:
$tmp -m mode
    -m app  : Applications
    -m fnc  : Functions
    -m mgr  : Manager Interface commands
    -m agi  : AGI commands
    -m cli  : CLI commands

HEREDOCEND;
$opts = getOpt('m:');
if (! is_array($opts) || ! array_key_exists('m', $opts)) {
	echo $usage ,"\n";
	exit(1);
}
switch ($opts['m']) {
	case 'applications' : $mode = 'app'; break;
	case 'functions'    : $mode = 'fnc'; break;
	case 'manager'      : $mode = 'mgr'; break;
	default             : $mode = $opts['m'];
}
if (! in_array($mode, array( 'app', 'fnc', 'mgr', 'agi', 'cli' ), true)) {
	echo "Invalid mode \"$mode\"!\n";
	echo $usage ,"\n";
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
	$out = array();
}
$out = _un_terminal_color(implode("\n", $out));
if (! preg_match('/Asterisk ([0-9.\-a-zA-Z]+)/', $out, $m)) {
	$err=0; $out=array();
	exec( 'asterisk -rx '. escapeShellArg('show version'), $out, $err );
	if ($err !== 0) {
		echo "\nERROR\n".implode("\n",$out)."\n\n";
		$out = array();
	}
	$out = _un_terminal_color(implode("\n", $out));
	if (! preg_match('/Asterisk ([0-9.\-a-zA-Z]+)/', $out, $m)) {
		echo "\nERROR. Failed to get version.\n\n";
		exit(1);
	}
}
$ast_vers_full = $m[1];
$ast_vers = $ast_vers_full;
if (preg_match('/^SVN-branch-/i', $ast_vers_full, $m)) {
	$ast_vers = subStr($ast_vers, strLen($m[0]));
}
if (preg_match('/^([0-9]+)\.([0-9]+)/', $ast_vers_full, $m)) {
	$ast_vers = $m[1].'.'.$m[2];
}
echo "ASTERISK VERSION: $ast_vers_full => $ast_vers\n";


$dir = dirName(__FILE__).'/';
switch ($mode) {
	case 'app': $dir.= 'applications'; break;
	case 'fnc': $dir.= 'functions'   ; break;
	case 'mgr': $dir.= 'manager'     ; break;
	case 'agi': $dir.= 'agi'         ; break;
	case 'cli': $dir.= 'cli'         ; break;
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
	case 'app': $rxn = 'core show applications'   ;
	            $rx1 = 'core show application %s' ;  break;
	case 'fnc': $rxn = 'core show functions'      ;
	            $rx1 = 'core show function %s'    ;  break;
	case 'mgr': $rxn = 'manager show commands'    ;
	            $rx1 = 'manager show command %s'  ;  break;
	case 'agi': $rxn = 'agi show'                 ;
	            $rx1 = 'agi show %s'              ;  break;
	case 'cli': $rxn = 'help'                     ;
	            $rx1 = 'help %s'                  ;  break;
	default : exit(1);
}
if ('x'.$ast_vers <= 'x1.4') {
	if (subStr($rxn,0,5) === 'core ') $rxn = subStr($rxn,5);
	if (subStr($rx1,0,5) === 'core ') $rx1 = subStr($rx1,5);
	if (subStr($rxn,0,13) === 'manager show ') $rxn = 'show manager '. subStr($rxn,13);
	if (subStr($rx1,0,13) === 'manager show ') $rx1 = 'show manager '. subStr($rx1,13);
	if (subStr($rxn,0,8) === 'agi show') $rxn = 'show agi'. subStr($rxn,8);
	if (subStr($rx1,0,8) === 'agi show') $rx1 = 'show agi'. subStr($rx1,8);
}
sleep(1);
$err=0; $out=array();
exec( 'asterisk -rx '. escapeShellArg($rxn), $out, $err );
if ($err !== 0) {
	echo "\nERROR\n".implode("\n",$out)."\n\n";
	exit(1);
}
sleep(1);
$m = array();
switch ($mode) {
	case 'app': $pat = '/^[ \t]*([A-Za-z][a-zA-Z0-9_]*)[ \t:]/m'; break;
	case 'fnc': $pat = '/^[ \t]*([A-Z][A-Z0-9_]+)[ \t:]/m'   ; break;
	case 'mgr': $pat = '/^[ \t]*([A-Z][a-zA-Z0-9_]*)[ \t:]/m'; break;
	case 'agi': $pat = '/^[ \t]*(?:Dead|Yes|No)?[ \t]*([a-zA-Z][a-zA-Z0-9_]*(?: [a-zA-Z0-9_]+)*)(?:  +|\t| *: *)([^\n\r]+)/m'; break;
	case 'cli': $pat = '/^[ \t]*([a-z][a-z0-9_]*(?: [a-z0-9_\\|\\[\\]\\{\\}]+)*)(?: +|\t| *: *)([^\n\r]+)/m'; break;
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


# fix command names which didn't fit into the column
#
$items2 = array();
foreach ($items as $item) {
	switch ($mode) {
		case 'mgr':
			switch (strToLower($item)) {
				case 'action'         : break;  # skip header line
				case         'agentcallbacklo':
				 $items2[] = 'AgentCallbackLogin' ; break;
				case         'coreshowchannel':
				 $items2[] = 'CoreShowChannels'   ; break;
				case         'dahdidialoffhoo':
				 $items2[] = 'DAHDIDialOffhook'   ; break;
				case         'dahdishowchanne':
				 $items2[] = 'DAHDIShowChannels'  ; break;
				case         'voicemailusersl':
				 $items2[] = 'VoicemailUsersList' ; break;
				default                       :
				 $items2[] = $item;  # copy
			}
			break;
		case 'agi':
			if ($item === 'Command') continue;  # skip header line
			$items2[] = $item;  # copy
			break;
		case 'cli':
			switch (strToLower($item)) {
				case         'ael set debug {read|tokens|mac':
				 $items2[] = 'ael set debug {read|tokens|macros|contexts|off}'     ; break;
				case         'core set {debug|verbose} [off|':
				 $items2[] = 'core set {debug|verbose} [off|atleast]'              ; break;
				case         'core show applications [like|d':
				 $items2[] = 'core show applications [like|describing]'            ; break;
				case         'core show channels [concise|ve':
				 $items2[] = 'core show channels [concise|verbose|count]'          ; break;
				case         'core show codecs [audio|video|':
				 $items2[] = 'core show codecs [audio|video|image]'                ; break;
				case         'dahdi show channels [trunkgrou':
				 $items2[] = 'dahdi show channels [trunkgroup|group|context]'      ; break;
				case         'dialplan set extenpatternmatch':
				 $items2[] = 'dialplan set extenpatternmatch [true|false]'         ; break;
				case         'dundi show peers [registered|i':
				 $items2[] = 'dundi show peers [registered|include|exclude|begin]' ; break;
				case         'sip show {channels|subscriptio':
				 $items2[] = 'sip show {channels|subscriptions}'                   ; break;
				default                                      :
					$items2[] = $item;  # copy
			}
			break;
		default:
			$items2[] = $item;  # copy
	}
}
unset($items);
sort($items2);



function _expand_cli_cmd( $combined_cmd )
{
	$cmds = array();
	
	# expand "{...|...|...}"
	if (preg_match_all('/\\{([^\\}]*)\\}/S', $combined_cmd, $mm, PREG_SET_ORDER+PREG_OFFSET_CAPTURE)) {
		print_r($mm);
	}
	
}


# expand item names
#
$items3 = array();
foreach ($items2 as $item) {
	switch ($mode) {
		case 'cli':
			switch (strToLower($item)) {
				
				
				default:
					if (preg_match('/[\\|\\[\\]\\{\\}]/S', $item)) {
						/*
						echo "\n ITEM \"$item\" NEEDS TO BE EXPANDED!\n";
						//_expand_cli_cmd($item);
						echo "\n\n";
						exit(1);
						*/
						# skip that crap
						continue;  //FIXME
					}
					$items3[] = $item;  # copy
			}
			break;
		default:
			$items3[] = $item;  # copy
	}
}
unset($items2);
sort($items3);


$c = count($items3);
$cl = strLen($c);
$cpad = str_pad($c,$cl,' ',STR_PAD_LEFT);
$i = 0;
foreach ($items3 as $item) {
	++$i;
	
	echo '(',str_pad($i,$cl,' ',STR_PAD_LEFT),'/',$cpad,')  ', $item ,"\n";
	
	usleep(100);
	$run_rx = true;
	
	if ($mode === 'cli'
	&&  'x'.$ast_vers      <= 'x1.2'
	//&&  'x'.$ast_vers_full <= 'x1.2.30.2'  //FIXME
	) {
		switch ($item) {
			case 'iax2 set jitter':
				# `asterisk -rx 'help iax2 set jitter'` does not return
				# http://bugs.digium.com/view.php?id=13963
				$out = <<<HEREDOCEND
Usage: iax set jitter [callid] <value>
       If used with a callid, it sets the jitter buffer to the given static
value (until its next calculation).  If used without a callid, the value is used
to establish the maximum excess jitter buffer that is permitted before the jitter
buffer size is reduced.
HEREDOCEND;
				$run_rx = false;
				break;
			case 'moh classes show':
				# `asterisk -rx 'help moh classes show'` does not return
				# http://bugs.digium.com/view.php?id=13964
				$out = <<<HEREDOCEND
Lists all MOH classes
HEREDOCEND;
				$run_rx = false;
				break;
			case 'moh files show':
				# `asterisk -rx 'help moh files show'` does not return
				# http://bugs.digium.com/view.php?id=13964
				$out = <<<HEREDOCEND
Lists all loaded file-based MOH classes and their files
HEREDOCEND;
				$run_rx = false;
				break;
			case 'moh reload':
				# `asterisk -rx 'help moh reload'` does not return
				# http://bugs.digium.com/view.php?id=13964
				$out = <<<HEREDOCEND
Music On Hold
HEREDOCEND;
				$run_rx = false;
				break;
		}
	}
	if ($run_rx) {
		$err=0; $out=array();
		exec( 'asterisk -rx '. escapeShellArg(sPrintF($rx1,$item)), $out, $err );
		if ($err !== 0) {
			echo "\nERROR\n".implode("\n",$out)."\n\n";
			exit(1);
		}
		$out = implode("\n", $out);
	}
	
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
	
	$fileb = $dir.'/'. preg_replace('/[^a-zA-Z0-9\-_.]/S', '-', strToLower($item)) .'-help-'.$ast_vers;
	
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
