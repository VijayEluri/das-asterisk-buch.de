#!/usr/bin/php
<?php

# sucht in ../docbook/applikationen.xml nach IDs von
# Applikationen, die beschrieben sind aber nicht im Index
# stehen oder die im Index stehen aber nicht existieren


$docbookDir = realPath( dirName(__FILE__) .'/../docbook/' ) .'/';
$appsFile = $docbookDir .'applikationen.xml';

$xml = file_get_contents($appsFile);


preg_match_all( '/<member>\s*<xref\s*linkend="(applikationen-[^"]*)"/', $xml, $m );
$imIndex = $m[1];
unset($m);
sort($imIndex);

preg_match_all( '/<section\sid="(applikationen-[^"]*)"/', $xml, $m );
$apps = $m[1];
unset($m);
sort($apps);


$imIndexAberNichtVorhanden = array_diff( $imIndex, $apps );
sort($imIndexAberNichtVorhanden);
echo "
Diese IDs sind im Index, existieren aber nicht:
=======================================================
";
foreach ($imIndexAberNichtVorhanden as $id) {
	echo $id, "\n";
}
echo "\n";
unset($imIndexAberNichtVorhanden);


$vorhandenAberNichtImIndex = array_diff( $apps, $imIndex );
sort($vorhandenAberNichtImIndex);
echo "
Diese IDs sind vorhanden, sind aber nicht im Index:
=======================================================
";
foreach ($vorhandenAberNichtImIndex as $id) {
	echo $id, "\n";
}
echo "\n";


?>
