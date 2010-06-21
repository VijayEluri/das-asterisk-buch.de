#!/usr/bin/php -q
<?php

# alle Pfade *mit* abschließendem Slash:
$myDir      = realPath(dirName(__FILE__).'/').'/';
$docbookDir = $myDir .'docbook/';
$htmlDir    = $myDir .'html/';
$html2Dir   = $myDir .'html2/';


set_time_limit(60*15);
set_magic_quotes_runtime(0);
ini_set('memory_limit', '50M');



$opts = getOpt('hu:p:tres');
if (array_key_exists('h',$opts)) {
	$help = '
    Optionen;
    ===============;

    -h                 Hilfe
    -u svnUsername     anderer Benutzer zum Auschecken als anonymous
    -p svnPassword     Passwort für den SVN-User
    -r                 nicht erneut Auschecken
    -t                 nicht erneut von Docbook nach HTML transformieren
    -e                 E-Mail-Adressen mit JS schuetzen
    -s                 mit SSI-Weiche für Internet Explorer

';
	echo $help;
	exit(0);
}




if (! file_exists( $myDir .'stylesheets/docbook-xsl/' )) {
	echo "Symlink zum Stylesheet fehlt.\n";
	echo "Im Verzeichnis stylesheets/ :\n";
	echo "ln -s docbook-xsl-1.72.0/ docbook-xsl\n";
	echo "\n";
	exit(1);
}



$u = array_key_exists('u',$opts) ? ("--username '". $opts['u'] ."'") : '';
$p = array_key_exists('p',$opts) ? ("--password '". $opts['p'] ."'") : '';

$ssi = array_key_exists('s',$opts);



echo "
Aus SVN auschecken ...
===============================================
";
if (! array_key_exists('r',$opts)){
	exec ("svn co $u $p 'https://svn.amooma.com/das-asterisk-buch/de/head/docbook/' '$docbookDir'", $out, $err);
	echo implode("\n", $out), "\n";
	if ($err != 0) {
		echo "Fehler beim Auschecken!\n";
		exit(1);
	}
} else
	echo "uebersprungen
";




$params = array(
	'use.id.as.filename'         => '1',      # sprechende Dateinamen
	'html.stylesheet'            => 'css/style.css',  # eigenes CSS
	'admon.graphics'             => '1',      # Icons für z.B. note
	'admon.graphics.path'        => 'img/',
	'admon.graphics.extension'   => '.gif',
	'admon.textlabel'            => '0',
	'toc.section.depth'          => '10',     # depth of the TOC
	'toc.max.depth'              => '10',     # max. depth of the TOC
	'generate.section.toc.level' => '0',      # depth of sections with TOCs
	'generate.toc'               => 'book toc',
	'chapter.autolabel'          => '1',      # arabic (1, 2, 3 ...)
	//'section.autolabel'          => '1',      # arabic (1, 2, 3 ...)
	'section.autolabel.max.depth'=> '2',
	//'section.label.includes.component.label' => '1',
	'appendix.autolabel'         => 'A',      # uppercase latin (A, B, C ...)
	//'preface.autolabel'          => 'i',      # lowercase roman (i, ii, iii ...)
	'chunker.output.indent'      => 'yes',
	'chunker.output.omit-xml-declaration' => 'yes',
	'html.extra.head.links'      => '1',
	'chunk.fast'                 => '1',
	'chunk.section.depth'        => '2',      # bis zu welcher Tiefe chunken
	'chunk.first.sections'       => '1',
	'chunk.tocs.and.lots'        => '1',
	'navig.graphics'             => '1',
	'navig.graphics.path'        => 'img/',
	'navig.graphics.extension'   => '.gif',
	'navig.showtitles'           => '1',
	'ulink.target'               => '_blank', # externe Links in neuem Fenster
	'ignore.image.scaling'       => '1',
	
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

function unHtmlEntities( $text ) {
	// numerische Entities ersetzen:
	$text = preg_replace('/&#x([0-9A-F]+);/ie', 'chr(hexDec("\\1"))', $text);
	$text = preg_replace('~&#([0-9]+);~e', 'chr("\\1")', $text);
	// benannte Entities ersetzen:
	return html_entity_decode( $text, ENT_QUOTES );
}

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

function my_wordWrap_htmlEnt( $text, $len=72, $split="\n" ) {
	$text = unHtmlEntities( $text );
	$text = my_wordWrap( $text, $len=72, $split="\n" );
	return htmlSpecialChars( $text, ENT_QUOTES, 'UTF-8' );
}

function replacePre( $arr ) {
	$text = $arr[2];
	$text = preg_replace( '/\r/', "\n", $text );
	//$text = wordWrap($text, 70, "\n".'<img src="img/sb.gif" alt="" />', true);
	$text = my_wordWrap_htmlEnt($text, 80, "\n".'<img src="img/sb.gif" alt="" />');
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
$bottom = file_get_contents( $myDir .'bottom.inc.html' );

$html1TblOpen  = '<table id="outer-t">';
$html1TrOpen   = '<tr id="outer-tr">';
$html1TdSlOpen = '<td id="sidebar-left">';
$html1TdCcOpen = '<td id="content-container">';
$html1TdSrOpen = '<td id="sidebar-right">';
$html1TdClose  = '</td>';
$html1TrClose  = '</tr>';
$html1TblClose = '</table>';

$html2TblOpen  = '<div id="outer-t">';
$html2TrOpen   = '<div id="outer-tr">';
$html2TdSlOpen = '<div id="sidebar-left">';
$html2TdCcOpen = '<div id="content-container">';
$html2TdSrOpen = '<div id="sidebar-right">';
$html2TdClose  = '</div>';
$html2TrClose  = '</div>';
$html2TblClose = '</div>';

if (! $ssi) {
	$htmlTblOpen  = $html2TblOpen;
	$htmlTrOpen   = $html2TrOpen;
	$htmlTdSlOpen = $html2TdSlOpen;
	$htmlTdCcOpen = $html2TdCcOpen;
	$htmlTdSrOpen = $html2TdSrOpen;
	$htmlTdClose  = $html2TdClose;
	$htmlTrClose  = $html2TrClose;
	$htmlTblClose = $html2TblClose;
} else {
	$ssiMsieOpen = '<!--#if expr="$HTTP_USER_AGENT=/MSIE/" -->';
	$ssiElse     = "\n".'<!--#else -->';
	$ssiEnd      = '<!--#endif -->'."\n";
	$htmlTblOpen  = $ssiMsieOpen . $html1TblOpen  . $ssiElse . $html2TblOpen  . $ssiEnd;
	$htmlTrOpen   = $ssiMsieOpen . $html1TrOpen   . $ssiElse . $html2TrOpen   . $ssiEnd;
	$htmlTdSlOpen = $ssiMsieOpen . $html1TdSlOpen . $ssiElse . $html2TdSlOpen . $ssiEnd;
	$htmlTdCcOpen = $ssiMsieOpen . $html1TdCcOpen . $ssiElse . $html2TdCcOpen . $ssiEnd;
	$htmlTdSrOpen = $ssiMsieOpen . $html1TdSrOpen . $ssiElse . $html2TdSrOpen . $ssiEnd;
	$htmlTdClose  = $ssiMsieOpen . $html1TdClose  . $ssiElse . $html2TdClose  . $ssiEnd;
	$htmlTrClose  = $ssiMsieOpen . $html1TrClose  . $ssiElse . $html2TrClose  . $ssiEnd;
	$htmlTblClose = $ssiMsieOpen . $html1TblClose . $ssiElse . $html2TblClose . $ssiEnd;
}


foreach (glob($htmlDir.'*.html') as $filename) {
	$baseName = baseName( $filename );
	echo 'bearbeite ', $baseName, " ...\n";
	
	$href = ($baseName != 'index.html') ? $baseName : '';
	
	$menu = buildHtmlToc( $toc, $href );
	
	$html = file_get_contents( $htmlDir . $baseName );
	$html = preg_replace_callback( '/<pre([^>]*)>([^<]*)<\/pre>/', 'replacePre', $html );
	
	$html = preg_replace( '/(<body[^>]*>)/', '$1
'. $htmlTblOpen . $htmlTrOpen .'

<!-- ++++++++++++++++++++++++ SIDEBAR LEFT +++++++++++++++++++++++++ -->

'. $htmlTdSlOpen .'
'. $menu .'
'. $htmlTdClose .'

<!-- +++++++++++++++++++++++++++ CONTENT +++++++++++++++++++++++++++ -->

'. $htmlTdCcOpen .'
', $html );
	$html = preg_replace( '/(<\/body>)/', '
'. $htmlTdClose .'

<!-- ++++++++++++++++++++++++ SIDEBAR RIGHT ++++++++++++++++++++++++ -->

'. $htmlTdSrOpen .'
'. $werbung .'
'. $htmlTdClose .'

'. $htmlTrClose . $htmlTblClose .'

<!-- +++++++++++++++++++++++++++ BOTTOM ++++++++++++++++++++++++++++ -->

'. $bottom .'
$1', $html );
	
	if (array_key_exists('e',$opts)) {
		$html = preg_replace_callback( '/<a\s+href="mailto:[^@]+@[a-z.\-_0-9]+\.[a-z]+"[^>]*>([^@]+@[a-z.\-_0-9]+\.[a-z]+)<\/a>/', 'replaceEmail', $html );
	}
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
//passthru( "cp -r '".$myDir."trackvp' '".$html2Dir."/'" );
passthru( "cp -r '".$docbookDir."bilder' '".$html2Dir."/'" );
passthru( "cp -r '".$docbookDir."screenshots' '".$html2Dir."/'" );


echo "
Done.

";

?>
