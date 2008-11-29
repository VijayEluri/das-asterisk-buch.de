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
$usage = <<<HEREDOCEND
Usage:
$tmp -m mode -l language

    -m app  : Applications
    -m fnc  : Functions
    -m mgr  : Manager Interface commands
    -m agi  : AGI commands
    -m cli  : CLI commands

    -l de   : Deutsch
    -l en   : English

HEREDOCEND;
$opts = getOpt('m:l:');
if (! is_array($opts)
||  ! array_key_exists('m', $opts)
||  ! array_key_exists('l', $opts)
){
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
if (! in_array($mode, array( 'app', 'fnc', 'mgr', 'agi' ), true)) {
	echo "Mode \"$mode\" not implemented!\n";
	echo $usage ,"\n";
	exit(1);
}

$lang = $opts['l'];
if (! in_array($lang, array( 'de', 'en' ), true)) {
	echo "Invalid language \"$lang\"!\n";
	echo $usage ,"\n";
	exit(1);
}


$ids = array(
	'app' => 'applications-%s',
	'fnc' => 'functions-%s',
	'mgr' => 'manager-%s',
	'agi' => 'agi-%s',
	'cli' => 'cli-%s',
);

$dirs_help = array(
	'app' => 'applications-help',
	'fnc' => 'functions-help',
	'mgr' => 'manager-help',
	'agi' => 'agi-help',
	'cli' => 'cli-help',
);

$dirs_out = array(
	'app' => 'applications',
	'fnc' => 'functions',
	'mgr' => 'manager',
	'agi' => 'agi',
	'cli' => 'cli',
);

$dir_help = dirName(__FILE__).'/../docbook/anhang/'.$dirs_help[$mode].'/';
$dir_out  = dirName(__FILE__).'/../docbook/anhang/'.$dirs_out[$mode].'/';

switch ($lang) {
	case 'de':
		$versions_title = 'Asterisk-Versionen:';
		break;
	case 'en':
		$versions_title = 'Asterisk versions:';
		break;
}

switch ($lang) {
	case 'de':
		$renamed_text = 'anderer Name';
		break;
	case 'en':
		$renamed_text = 'different name';
		break;
}

switch ($lang) {
	case 'de':
		$help_title = 'Interner Hilfetext %s in Asterisk %s:';
		switch ($mode) {
			case 'app': $of = 'zu dieser Applikation'   ; break;
			case 'fnc': $of = 'zu dieser Funktion'      ; break;
			case 'mgr': $of = 'zu diesem AMI-Befehl'    ; break;
			case 'agi': $of = 'zu diesem AGI-Befehl'    ; break;
			case 'cli': $of = 'zu diesem CLI-Befehl'    ; break;
		}
		break;
	case 'en':
		$help_title = 'Internal help %s in Asterisk %s:';
		switch ($mode) {
			case 'app': $of = 'for this application'    ; break;
			case 'fnc': $of = 'for this function'       ; break;
			case 'mgr': $of = 'for this AMI command'    ; break;
			case 'agi': $of = 'for this AGI command'    ; break;
			case 'cli': $of = 'for this CLI command'    ; break;
		}
		break;
}

switch ($lang) {
	case 'de':
		$not_avail_text = '- in Asterisk %s nicht vorhanden -';
		break;
	case 'en':
		$not_avail_text = '- not available in Asterisk %s -';
		break;
}

switch ($lang) {
	case 'de':
		$help_diff_title = 'Differenz des internen Hilfetexts von Asterisk %s zu %s:';
		break;
	case 'en':
		$help_diff_title = 'Diff of the internal help from Asterisk %s to %s:';
		break;
}

switch ($lang) {
	case 'de':
		$no_difference_text = '- keine -';
		break;
	case 'en':
		$no_difference_text = '- none -';
		break;
}

switch ($lang) {
	case 'de':
		$see_other_text = 'siehe <xref linkend="%s" />';
		break;
	case 'en':
		$see_other_text = 'see <xref linkend="%s" />';
		break;
}

switch ($lang) {
	case 'de':
		$in_asterisk_text = 'in Asterisk %s';
		break;
	case 'en':
		$in_asterisk_text = 'in Asterisk %s';
		break;
}



$svn_revision_keyword = '$'.'Revision: 0 '.'$';

$container_xml = <<<HEREDOCEND
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE note PUBLIC "-//OASIS//DTD DocBook XML V4.5//EN"
"http://www.oasis-open.org/docbook/xml/4.3/docbookx.dtd">
<!-- AUTO-GENERATED FILE. DO NOT EDIT. -->
<note lang="$lang" revision="$svn_revision_keyword">
%s
</note>

HEREDOCEND;

$help_or_diff_container_xml = <<<HEREDOCEND

  <formalpara>
    <title>%s</title>

    <para>%s</para>
  </formalpara>

HEREDOCEND;

$help_avail_xml = <<<HEREDOCEND
<screen lang="en-US">%s</screen>
HEREDOCEND;

$diff_avail_xml = <<<HEREDOCEND
<screen lang="en-US" language="diff-u">%s</screen>
HEREDOCEND;

$help_or_diff_not_avail_xml = <<<HEREDOCEND
%s
HEREDOCEND;



function file_to_shortname( $filename )
{
	return preg_replace('/-help-\\d+\\.\\d+(?:\\.\\d+)?\\.txt$/S', '', baseName($filename));
}

function _preg_grep_o( $pattern, $input )
{
	if (preg_match( $pattern, $input, $m )) {
		return $m[0];
	} else {
		return false;
	}
}

function _diff_files( $file_a, $file_b )
{
	global $in_asterisk_text;
	
	if (! file_exists($file_a)) return false;
	if (! file_exists($file_b)) return false;
	
	$label_a = sPrintF($in_asterisk_text, _preg_grep_o('/\\d+\\.\\d+(?:\\.\\d+)?/S', baseName($file_a,'.txt')));
	$label_b = sPrintF($in_asterisk_text, _preg_grep_o('/\\d+\\.\\d+(?:\\.\\d+)?/S', baseName($file_b,'.txt')));
	
	$cmd = 'diff --text --minimal --suppress-common-lines --unified=3 -T --label '. escapeShellArg($label_a) .' '. escapeShellArg($file_a) .' --label '. escapeShellArg($label_b) .' '. escapeShellArg($file_b) .' 2>&1';
	$err=0; $out=array();
	exec($cmd, $out, $err);
	if ($err == 0) {  # no difference
		return '';
	}
	if ($err == 1) {  # diff generated
		$out = implode("\n", $out);
		$out = preg_replace('/^(\\+|-)\\t/mS', '$1  ', $out);
		$out = preg_replace('/^\\t/mS', '   ', $out);
		return $out;
	}
	if ($err != 0) {
		var_export($out);
		return false;
	}
}


# get list of items
#
$files = glob( $dir_help.'*-help-1.*.txt');
$items = array();
foreach ($files as $file) {
	if (fileSize($file) < 2) continue;
	//$file = baseName($file);
	$short = file_to_shortname( $file );
	$short = strToLower($short);
	//echo $file ,"\n";
	if (! preg_match('/-(\\d+\\.\\d+)\\./', $file, $m)) continue;
	$vers = 'v'.$m[1];
	
	if (! is_array($items[$short])) {
		$items[$short] = array(
			'see' => false
		);
	}
	$items[$short][$vers] = $file;
}
kSort($items);


function _is_avail( &$items, $item, $vers )
{
	return
		(  array_key_exists($item, $items)
		&& array_key_exists('v'.$vers, $items[$item])
		);
}


foreach ($items as $itemname => $item) {
	switch ($mode) {
		case 'app':
		case 'mgr':
			if (subStr($itemname,0,3)==='zap') {
				$othervers = '1.6';
				if (! _is_avail( &$items, $itemname, $othervers )) {
					$othername = 'dahdi'.subStr($itemname,3);
					if (_is_avail( &$items, $othername, $othervers )) {
						$items[$itemname] += array('v'.$othervers => $items[$othername]['v'.$othervers]);
						//unset($items[$othername]['v'.$othervers]);
						$items[$othername]['see'] = $itemname;
					}
				}
			}
			elseif (subStr($itemname,0,5)==='dahdi') {
				$othervers = '1.2';
				if (! _is_avail( &$items, $itemname, $othervers )) {
					$othername = 'zap'.subStr($itemname,5);
					if (_is_avail( &$items, $othername, $othervers )) {
						$items[$itemname] += array('v'.$othervers => $items[$othername]['v'.$othervers]);
						//unset($items[$othername]['v'.$othervers]);
						$items[$othername]['see'] = $itemname;
					}
				}
				$othervers = '1.4';
				if (! _is_avail( &$items, $itemname, $othervers )) {
					$othername = 'zap'.subStr($itemname,5);
					if (_is_avail( &$items, $othername, $othervers )) {
						$items[$itemname] += array('v'.$othervers => $items[$othername]['v'.$othervers]);
						//unset($items[$othername]['v'.$othervers]);
						$items[$othername]['see'] = $itemname;
					}
				}
			}
			break;
	}
}

//print_r($items);

/*
foreach ($items as $itemname => $item) {
	if (subStr($itemname,0,3)==='zap'
	||  subStr($itemname,0,5)==='dahdi'
	){
		echo "\n";
		echo $itemname,"\n";
		print_r($item);
	}
}
*/

function _xmlent( $str )
{
	return str_replace('&#039;', '&apos;', htmlSpecialChars($str, ENT_QUOTES, 'UTF-8'));
}


foreach ($items as $itemname => $item) {
	//$out = $container_xml;
	/*
	if (! empty($item['see'])) {
		$out = sPrintF($out, $help_or_diff_container_xml);
		
		echo $out;
		echo "\n\n\n";
	}
	*/
	
	if (subStr($itemname,0,5) === 'dahdi'
	&&  _is_avail( &$items, $itemname, '1.6' )) {
		$ast_vers_main_help = '1.6';
		$do_diff_if_avail_12_14 = true;
		$do_diff_if_avail_14_16 = true;
	} else {
		if (_is_avail( &$items, $itemname, '1.4' )) {
			$ast_vers_main_help = '1.4';
			$do_diff_if_avail_12_14 = true;
			$do_diff_if_avail_14_16 = true;
		}
		elseif (_is_avail( &$items, $itemname, '1.6' )) {
			$ast_vers_main_help = '1.6';
			$do_diff_if_avail_12_14 = false;
			$do_diff_if_avail_14_16 = true;
		}
		elseif (_is_avail( &$items, $itemname, '1.2' )) {
			$ast_vers_main_help = '1.2';
			$do_diff_if_avail_12_14 = true;
			$do_diff_if_avail_14_16 = false;
		}
		else {
			echo "Huh? Not available in any version?\n";
			exit(1);
		}
	}
	
	echo str_pad($itemname, 35, ' ') ,'  (main: ', $ast_vers_main_help ,')' ,"\n";
	
	$out = '';
	
	
	$title = $versions_title;
	$content = '';
	$nbsp = '&#x00A0;';  # non-breaking space
	$was_renamed = false;
	if (true
	&&  _is_avail(&$items, $itemname, '1.2')) {
		$content.= str_repeat('&#x2014;',8);  # em dash
	} else {
		$content.= str_repeat($nbsp     ,8);
	}
	if (_is_avail(&$items, $itemname, '1.2')) {
		$content.= '|'.$nbsp.'<emphasis role="bold">1.2</emphasis>';
		if (subStr(baseName($items[$itemname]['v1.2']), 0, strLen($itemname)) === $itemname) {
			$content.= $nbsp;
		} else {
			$content.= '*';
			$was_renamed = true;
		}
		//$content.= '('. subStr(baseName($items[$itemname]['v1.2']) .')';
		$content.= '|';
	} else {
		$content.= '|'.str_repeat($nbsp,5).'|';
	}
	if (_is_avail(&$items, $itemname, '1.2')
	&&  _is_avail(&$items, $itemname, '1.4')) {
		$content.= str_repeat('&#x2014;',8);  # em dash
	} else {
		$content.= str_repeat($nbsp     ,8);
	}
	if (_is_avail(&$items, $itemname, '1.4')) {
		$content.= '|'.$nbsp.'<emphasis role="bold">1.4</emphasis>';
		if (subStr(baseName($items[$itemname]['v1.4']), 0, strLen($itemname)) === $itemname) {
			$content.= $nbsp;
		} else {
			$content.= '*';
			$was_renamed = true;
		}
		$content.= '|';
	} else {
		$content.= '|'.str_repeat($nbsp,5).'|';
	}
	if (_is_avail(&$items, $itemname, '1.4')
	&&  _is_avail(&$items, $itemname, '1.6')) {
		$content.= str_repeat('&#x2014;',8);  # em dash
	} else {
		$content.= str_repeat($nbsp     ,8);
	}
	if (_is_avail(&$items, $itemname, '1.6')) {
		$content.= '|'.$nbsp.'<emphasis role="bold">1.6</emphasis>';
		if (subStr(baseName($items[$itemname]['v1.6']), 0, strLen($itemname)) === $itemname) {
			$content.= $nbsp;
		} else {
			$content.= '*';
			$was_renamed = true;
		}
		$content.= '|';
	} else {
		$content.= '|'.str_repeat($nbsp,5).'|';
	}
	if (_is_avail(&$items, $itemname, '1.6')
	&&  true                                ) {
		$content.= str_repeat('&#x2014;',8);  # em dash
	} else {
		//$content.= str_repeat($nbsp     ,8);
	}
	$content = '<literallayout class="monospaced">'. $content .'</literallayout>';
	if ($was_renamed) $content.= "\n". ' (* '.$renamed_text.')';
	$out.= sPrintF($help_or_diff_container_xml, $title, $content);
	
	
	//if (true) {  # we have already checked that it's available in Asterisk $ast_vers_main_help
		$title = sPrintF($help_title, $of, $ast_vers_main_help);
		$help = rTrim(@file_get_contents($items[$itemname]['v'.$ast_vers_main_help]), "\n\r");
		$content = sPrintF($help_avail_xml, str_replace('%','%%', _xmlent($help)));
		$out.= sPrintF($help_or_diff_container_xml, $title, $content);
	//}
	
	if ($do_diff_if_avail_12_14) {
		if (! _is_avail( &$items, $itemname, '1.4' )) {
			$title = sPrintF($help_diff_title, '1.2', '1.4');
			$content = sPrintF($help_or_diff_not_avail_xml, sPrintF($not_avail_text, '1.4'));
		}
		elseif (! _is_avail( &$items, $itemname, '1.2' )) {
			$title = sPrintF($help_diff_title, '1.2', '1.4');
			$content = sPrintF($help_or_diff_not_avail_xml, sPrintF($not_avail_text, '1.2'));
		}
		else {
			$from_vers_text = '1.2';
			$to_vers_text = '1.4';
			$othername = file_to_shortname( $items[$itemname]['v'.'1.2'] );
			if ($othername !== $itemname) {
				$from_vers_text .= ' (<xref linkend="'. sPrintF($ids[$mode], $othername) .'" />)';
			}
			$othername = file_to_shortname( $items[$itemname]['v'.'1.4'] );
			if ($othername !== $itemname) {
				$to_vers_text   .= ' (<xref linkend="'. sPrintF($ids[$mode], $othername) .'" />)';
			}
			$title = sPrintF($help_diff_title, $from_vers_text, $to_vers_text);
			$diff = _diff_files(
				$items[$itemname]['v'.'1.2'],
				$items[$itemname]['v'.'1.4'] );
			if ($diff === false) {echo "ERROR.\n"; exit(1);}
			$diff = rTrim($diff,"\n\r");
			if ($diff != '') {
				$content = sPrintF($diff_avail_xml, str_replace('%','%%', _xmlent($diff)));
			} else {
				$content = sPrintF($help_or_diff_not_avail_xml, str_replace('%','%%', _xmlent($no_difference_text)));
			}
		}
		$out.= sPrintF($help_or_diff_container_xml, $title, $content);
	}
	
	if ($do_diff_if_avail_14_16) {
		if (! _is_avail( &$items, $itemname, '1.4' )) {
			$title = sPrintF($help_diff_title, '1.4', '1.6');
			$content = sPrintF($help_or_diff_not_avail_xml, sPrintF($not_avail_text, '1.4'));
		}
		elseif (! _is_avail( &$items, $itemname, '1.6' )) {
			$title = sPrintF($help_diff_title, '1.4', '1.6');
			$content = sPrintF($help_or_diff_not_avail_xml, sPrintF($not_avail_text, '1.6'));
		}
		else {
			$from_vers_text = '1.4';
			$to_vers_text = '1.6';
			$othername = file_to_shortname( $items[$itemname]['v'.'1.4'] );
			if ($othername !== $itemname) {
				$from_vers_text .= ' (<xref linkend="'. sPrintF($ids[$mode], $othername) .'" />)';
			}
			$othername = file_to_shortname( $items[$itemname]['v'.'1.6'] );
			if ($othername !== $itemname) {
				$to_vers_text   .= ' (<xref linkend="'. sPrintF($ids[$mode], $othername) .'" />)';
			}
			$title = sPrintF($help_diff_title, $from_vers_text, $to_vers_text);
			$diff = _diff_files(
				$items[$itemname]['v'.'1.4'],
				$items[$itemname]['v'.'1.6'] );
			if ($diff === false) {echo "ERROR.\n"; exit(1);}
			$diff = rTrim($diff,"\n\r");
			if ($diff != '') {
				$content = sPrintF($diff_avail_xml, str_replace('%','%%', _xmlent($diff)));
			} else {
				$content = sPrintF($help_or_diff_not_avail_xml, str_replace('%','%%', _xmlent($no_difference_text)));
			}
		}
		$out.= sPrintF($help_or_diff_container_xml, $title, $content);
	}
	
	$out = sPrintF($container_xml, str_replace('%','%%', $out));
	
	
	$filename = $dir_out . $itemname .'-help.xml';
	$fh = @fOpen($filename, 'wb');
	@fWrite($fh, $out, strLen($out));
	@fClose($fh);
	
	//echo $out ,"\n\n\n";
}

# generated files should be included like so:
# <xi:include href="appname-help.xml" xmlns:xi="http://www.w3.org/2001/XInclude" parse="xml" xpointer="xpointer(/note/*)" />


