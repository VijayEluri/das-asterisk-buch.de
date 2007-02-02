#!/usr/bin/php
<?php

# alle Pfade *mit* abschließendem Slash:
$myDir      = realPath(dirName(__FILE__).'/').'/';
$docbookDir = $myDir .'docbook/';
$htmlDir    = $myDir .'html/';
$html2Dir   = $myDir .'html2/';


set_time_limit(60*15);
set_magic_quotes_runtime(0);
ini_set('memory_limit', '50M');



$opts = getOpt('hu:p:tr');
if (array_key_exists('h',$opts)) {
	$help = '
    Optionen;
    ===============;

    -h                 Hilfe
    -u svnUsername     anderer Benutzer zum Auschecken als anonymous
    -p svnPassword     Passwort für den SVN-User
    -r                 nicht erneut Auschecken
    -t                 nicht erneut von Docbook nach HTML transformieren

';
	echo $help;
	exit(0);
}

if (array_key_exists('u',$opts))
	$u = "--username '". $opts['b'] ."'";
else
	$u = '';
if (array_key_exists('p',$opts))
	$p = "--password '". $opts['p'] ."'";
else
	$p = '';

echo "
Aus SVN auschecken ...
===============================================
";
if (! array_key_exists('r',$opts)){
	passthru ("svn co $u $p 'https://svn.amooma.com/das-asterisk-buch/docbook/' '$docbookDir'");
} else
	echo "uebersprungen
";




$params = array(
	'use.id.as.filename'       => '1',              # sprechende Dateinamen
	'html.stylesheet'          => 'css/style.css',  # eigenes CSS
	'admon.graphics'           => '1',              # Icons für z.B. note
	'admon.graphics.path'      => 'img/',
	'admon.graphics.extension' => '.gif',
	'admon.textlabel'          => '0',
	'toc.section.depth'        => '10',              # depth of the TOC
	'toc.max.depth'            => '10',              # max. depth of the TOC
	'generate.section.toc.level' => '0',  # depth of sections with TOCs
	'generate.toc' => 'book toc',
	'chapter.autolabel'        => '1',  # arabic (1, 2, 3 ...)
	//'section.autolabel'        => '1',  # arabic (1, 2, 3 ...)
	'section.autolabel.max.depth' => '2',
	//'section.label.includes.component.label' => '1',
	'appendix.autolabel'       => 'A',  # uppercase latin (A, B, C ...)
	//'preface.autolabel'        => 'i',  # lowercase roman (i, ii, iii ...)
	'chunker.output.indent'    => 'yes',
	'chunker.output.omit-xml-declaration' => 'yes',
	'html.extra.head.links'    => '1',
	'chunk.fast' => '1',
	'chunk.section.depth'      => '2',  # bis zu welcher Tiefe gechunkt werden soll
	'chunk.first.sections'     => '1',
	'chunk.tocs.and.lots' => '1',
	'navig.graphics'           => '1',
	'navig.graphics.path'      => 'img/',
	'navig.graphics.extension' => '.gif',
	'navig.showtitles'         => '1',
	'ulink.target'             => '_blank',  # externe Links in neuem Fenster
	'ignore.image.scaling'     => '1',
	
);







//$xslt = "xsltproc --nonet --novalid --xinclude --output mytoc.xml --stringparam use.id.as.filename 1 stylesheets/docbook-xsl/xhtml/maketoc.xsl docbook/das-asterisk-buch.xml";





$xslt = "xsltproc --nonet --novalid --xinclude \
--stringparam 'base.dir' '".$htmlDir."' \
";
foreach ($params as $param => $value) {
	$xslt.= "--stringparam '$param' '$value' \
";
}
$xslt.= "'".$myDir."stylesheets/docbook-xsl/xhtml/chunk.xsl' \
'".$docbookDir."/das-asterisk-buch.xml'";


passthru( "rm -rf ".$html2Dir."*" );


echo "
XSL-Transformation ...
===============================================
";
if (!array_key_exists('t',$opts))
	passthru( $xslt );
else
	echo "uebersprungen
";

echo "
TOC parsen ...
===============================================
";
include( './inc/toc_to_struct.inc.php' );
$toc = @bookTocToStruct( $htmlDir .'bk01-toc.html' );


echo "
HTML-Files verarbeiten ...
===============================================
";

function my_wordWrap( $text, $len=72, $split="\n" ) {
	$lines = explode("\n", $text);
	$newText = '';
	foreach ($lines as $line) {
		if (mb_strLen($line) <= $len) {
			$newText .= $line ."\n";
		} else {
			while (! (mb_strLen($line) <= $len)) {
				$newText .= mb_subStr($line, 0, $len) . $split;
				$line = mb_subStr($line, $len);
			}
			$newText .= $line ."\n";
		}
	}
	if (subStr($newText, -1)=="\n")
		$newText = subStr($newText, 0, -1);
	return $newText;
}

function replacePre( $arr ) {
	$text = $arr[2];
	$text = preg_replace( '/\r/', "\n", $text );
	//$text = wordWrap($text, 70, "\n".'<img src="img/sb.gif" alt="" />', true);
	$text = my_wordWrap($text, 80, "\n".'<img src="img/sb.gif" alt="" />');
	return '<pre'. $arr[1] .'>' . $text . '</pre>';
	return $arr[0];
}

function replaceEmail( $arr ) {
	static $counter = 0;
	++$counter;
	$email = $arr[1];
	$email = str_replace(
		array('a','e','n','o','u','i','m','k','@','.'),
		array('=','*',':',',',';','(',')','#','$','!'),
		$email
	);
	
	return '<span class="email-obfuscated" id="email-obf-'. $counter .'"><small>[E-Mail nur mit JavaScript sichtbar]</small></span>
<script type="text/javascript">/*<![CDATA[*/
try {
var e = "'. $email .'";
e = e.replace(/=/g,"a").replace(/\\*/g,"e").replace(/:/g,"n").replace(/,/g,"o").replace(/;/g,"u").replace(/\\(/g,"i").replace(/\\)/g,"m").replace(/#/g,"k").replace(/\\$/g,"@").replace(/!/g,".");
document.getElementById("email-obf-'. $counter .'").innerHTML = "<a href=\"mailto:"+ e +"\">"+ e +"</a>";
} catch(e){}
/*]]>*/</script>';
}

$werbung = file_get_contents( $myDir .'werbung.inc.html' );
foreach (glob($htmlDir.'*.html') as $filename) {
	$baseName = baseName( $filename );
	echo 'bearbeite ', $baseName, " ...\n";
	
	$href = ($baseName != 'index.html') ? $baseName : '';
	
	$menu = buildHtmlToc( $toc, $href );
	
	$html = file_get_contents( $htmlDir . $baseName );
	$html = preg_replace_callback( '/<pre([^>]*)>([^<]*)<\/pre>/', 'replacePre', $html );
	$html = preg_replace( '/(<body[^>]*>)/', '$1<table id="outer" cellspacing="0"><tr><td id="sidebar-left">'. $menu .'</td><td id="content-container">', $html );
	$html = preg_replace( '/(<\/body>)/', '</td><td id="sidebar-right">'. $werbung .'</td></tr></table>', $html );
	$html = preg_replace_callback( '/<a\s+href="mailto:[^@]+@[a-z.\-_0-9]+\.[a-z]+"[^>]*>([^@]+@[a-z.\-_0-9]+\.[a-z]+)<\/a>/', 'replaceEmail', $html );
	$html = str_replace( '</head>', '<link rel="shortcut icon" href="favicon.ico" type="image/x-icon" />
<script type="text/javascript" src="aux.js"></script>
</head>', $html );
	$html = preg_replace( '/(<a\s+accesskey="t"\s+href="bk01-toc.html">)[^<]*(<\/a>)/', '$1<img src="img/toc.gif" alt="Inhaltsverzeichnis" />$2', $html );
	$html = preg_replace( '/<\/html>/', "\n<!-- Seite erzeugt am ". date('Y-m-d') ." um ". date('H:i T') ." -->\n</html>", $html );
	
	$fh = fOpen( $html2Dir . $baseName, 'wb' );
	fWrite($fh, $html, strLen($html));
	fClose($fh);
}

echo "
Bilder und CSS kopieren ...
===============================================
";
passthru( "cp -r '".$myDir."stylesheets/docbook-xsl/images' '".$html2Dir."/img'" );
passthru( "cp -r ".$myDir."img/* '".$html2Dir."/img/'" );
passthru( "cp -r '".$myDir."css' '".$html2Dir."/'" );
passthru( "cp -r '".$myDir."favicon.ico' '".$html2Dir."/'" );
passthru( "cp -r '".$myDir."aux.js' '".$html2Dir."/'" );
passthru( "cp -r '".$docbookDir."bilder' '".$html2Dir."/'" );
passthru( "cp -r '".$docbookDir."screenshots' '".$html2Dir."/'" );


echo "
Done.

";

?>