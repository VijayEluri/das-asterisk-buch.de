#!/usr/bin/php -q
<?php

$tmp = baseName($argv[0]);
$usage = <<<HEREDOCEND
Usage:
$tmp -m mode -l language

    -m app  : Applications
    -m fnc  : Functions

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
	default             : $mode = $opts['m'];
}
if (! in_array($mode, array( 'app', 'fnc' ), true)) {
	echo "Invalid mode \"$mode\"!\n";
	echo $usage ,"\n";
	exit(1);
}
if (! in_array($mode, array( 'app', 'fnc' ), true)) {
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


$dirs = array(
	'app' => 'applications',
	'fnc' => 'functions',
);

$dir  = dirName(__FILE__).'/../docbook/anhang/'.$dirs[$mode].'/';

echo "\n";
$files = glob( $dir.'*.xml');
foreach ($files as $file) {
	$short = baseName($file, '.xml');
	if (preg_match('/-help$/S', $short)) {
		# skip help files. we want the application files
		continue;
	}
	echo '[REPLACE]  ';
	echo str_pad($short.' ', 35, '.') ,' ';
	
	$xml = file_get_contents($file);
	if (preg_match('/<xi:include/', $xml)) {
		echo 'already converted' ,"\n";
		continue;
	}
	if (! preg_match_all('/<note>(?:.*)<\\/note>/UsS', $xml, $mm, PREG_SET_ORDER+PREG_OFFSET_CAPTURE)) {
		echo 'ERROR: <note> NOT FOUND!' ,"\n";
		continue;
	}
	if (count($mm) > 1) {
		echo 'ERROR: MORE THAN 1 <note> FOUND!' ,"\n";
		echo "\n";
		continue;
	}
	if (! preg_match('/internen Hilfetext|internal help/', $mm[0][0][0])) {
		echo 'ERROR: UNKNOWN <note> FOUND!' ,"\n";
		continue;
	}
	//print_r($mm);
	
	$helpfile_basename = $short.'-help.xml';
	$helpfile_fullname = dirName($file).'/'. $helpfile_basename;
	if (! file_exists($helpfile_fullname)) {
		echo 'ERROR: HELP FILE "'.$helpfile_basename.'" NOT FOUND!' ,"\n";
		continue;
	}
	
	$xml
		= subStr($xml, 0, $mm[0][0][1])
		. '<xi:include href="'.$helpfile_basename.'" parse="xml" xmlns:xi="http://www.w3.org/2001/XInclude" xpointer="xpointer(/note/*)" />'
		. subStr($xml, $mm[0][0][1]+strLen($mm[0][0][0]));
	//echo $xml;
	
	$fh = @fOpen($file, 'wb');
	@fWrite($fh, $xml, strLen($xml));
	@fClose($fh);
	echo 'CONVERTED';
	
	echo "\n";
}

echo "\n\n";
sleep(2);



$files = glob( $dir.'*-help.xml');
foreach ($files as $file) {
	$short = baseName($file, '-help.xml');
	echo '[ADD MISSING]  ';
	echo str_pad($short.' ', 35, '.') ,' ';
	$appfile = dirName($file).'/'.$short.'.xml';
	if (file_exists($appfile)) {
		echo 'ok';
	} else {
		echo 'ERROR: MISSING '.$dirs[$mode].' FILE!';
		
		switch ($lang) {
			case 'de': $see_also_text = 'Siehe auch' ; break;
			case 'en': $see_also_text = 'See also'   ; break;
		}
		switch ($mode) {
			case 'app':
				switch ($lang) {
					case 'de': $dialplan_applications_text = 'Dialplan-Applikationen' ; break;
					case 'en': $dialplan_applications_text = 'Dialplan Applications'  ; break;
				}
				$out = <<<HEREDOCEND
<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE section PUBLIC "-//OASIS//DTD DocBook XML V4.3//EN"
"http://www.oasis-open.org/docbook/xml/4.3/docbookx.dtd">
<section id="applications-$short" lang="$lang" revision="$Revision: 0 $">
  <!--
% Copyright (c) 2006 - 2008 by 
% Stefan Wintermeyer <stefan.wintermeyer@amooma.de>
% Philipp Kempgen <philipp.kempgen@amooma.de>
% Permission is granted to copy, distribute and/or modify this document
% under the terms of the GNU Free Documentation License, Version 1.2
% or any later version published by the Free Software Foundation
% with no Invariant Sections, no Front-Cover Texts, and no Back-Cover
% Texts. A copy of the license is included in the section entitled "GNU
% Free Documentation License".
% Asterisk training and consulting is offered at http://www.amooma.de
-->

    <title><literal>FIXMEFIXMEFIXMEApplication()</literal></title>

    <indexterm significance="preferred">
      <primary>$dialplan_applications_text</primary>

      <secondary><code>FIXMEFIXMEFIXMEApplication()</code></secondary>
    </indexterm>

    <simpara>DOES SOMETHING</simpara>

    <synopsis>FIXMEFIXMEFIXMEApplication(<replaceable>param</replaceable>)</synopsis>

    <simpara>FULL DESCRIPTION</simpara>

    <programlisting>; FIXMEFIXMEFIXME EXAMPLE DIALPLAN
exten =&gt; 123,1,Answer()
exten =&gt; 123,n,FIXMEFIXMEFIXMEApplication()
exten =&gt; 123,n,Hangup()</programlisting>

    <xi:include href="$short-help.xml" parse="xml" xmlns:xi="http://www.w3.org/2001/XInclude" xpointer="xpointer(/note/*)" />

    <formalpara>
      <title>$see_also_text</title>

      <para><xref linkend="applications-FIXMEFIXMEFIXME" />, <xref
      linkend="applications-FIXMEFIXMEFIXME" /></para>
    </formalpara>
</section>

HEREDOCEND;
				break;
			case 'fnc':
				switch ($lang) {
					case 'de': $dialplan_functions_text = 'Dialplan-Funktionen' ; break;
					case 'en': $dialplan_functions_text = 'Dialplan Functions'  ; break;
				}
				$fnctitle = strToUpper($short);
				$out = <<<HEREDOCEND
<?xml version="1.0" encoding="ISO-8859-1"?>
<!DOCTYPE section PUBLIC "-//OASIS//DTD DocBook XML V4.3//EN"
"http://www.oasis-open.org/docbook/xml/4.3/docbookx.dtd">
<section id="functions-$short" lang="$lang" revision="$Revision: 0 $">
  <!--
% Copyright (c) 2006 - 2008 by 
% Stefan Wintermeyer <stefan.wintermeyer@amooma.de>
% Philipp Kempgen <philipp.kempgen@amooma.de>
% Permission is granted to copy, distribute and/or modify this document
% under the terms of the GNU Free Documentation License, Version 1.2
% or any later version published by the Free Software Foundation
% with no Invariant Sections, no Front-Cover Texts, and no Back-Cover
% Texts. A copy of the license is included in the section entitled "GNU
% Free Documentation License".
% Asterisk training and consulting is offered at http://www.amooma.de
-->

    <title><literal>{$fnctitle}()</literal><indexterm significance="preferred">
      <primary>$dialplan_functions_text</primary>

      <secondary><code>{$fnctitle}()</code></secondary>
    </indexterm></title>

    <synopsis>{$fnctitle}(<replaceable>param</replaceable>)</synopsis>

    <simpara>FULL DESCRIPTION</simpara>

    <programlisting>; FIXMEFIXMEFIXME EXAMPLE DIALPLAN
exten =&gt; 123,1,Answer()
exten =&gt; 123,n,Set({$fnctitle}()=FIXMEFIXMEFIXME)
exten =&gt; 123,n,Hangup()</programlisting>

    <xi:include href="$short-help.xml" parse="xml" xmlns:xi="http://www.w3.org/2001/XInclude" xpointer="xpointer(/note/*)" />

    <formalpara>
      <title>$see_also_text</title>

      <para><xref linkend="functions-FIXMEFIXMEFIXME" />, <xref
      linkend="functions-FIXMEFIXMEFIXME" /></para>
    </formalpara>
</section>

HEREDOCEND;
				break;
		}
		/*
		echo $out;
		exit;
		*/
		$fh = @fOpen($appfile, 'wb');
		@fWrite($fh, $out, strLen($out));
		@fClose($fh);
		echo '   - ADDED';
	}
	echo "\n";
}



sleep(2);

echo "\n\n\n\n\n\n\n";
$files = glob( $dir.'*.xml');
sort($files);
foreach ($files as $file) {
	$short = baseName($file, '.xml');
	if (preg_match('/-help$/S', $short)) {
		# skip help files. we want the application files
		continue;
	}
	//echo $short ,"\n";
	echo <<<HEREDOCEND

  <xi:include href="{$dirs[$mode]}/$short.xml" parse="xml"
              xmlns:xi="http://www.w3.org/2001/XInclude" />

HEREDOCEND;
}

echo "\n";
