<?php


function bookTocToStruct( $file ) {
	
	$tocHtml = file_get_contents( $file );
	$origTocHtml = $tocHtml;
	
	$tocHtml = preg_replace( '/<\/?(span|table|tr|td|th|img|hr|html|head|body|meta|title|link|h1|dl|dt)[^>]*>/', '', $tocHtml );
	
	
	preg_match_all( '/<(\/?)([a-z0-9]+)[^>]*>([^<]*)/', $tocHtml, $m, PREG_SET_ORDER );
	//print_r($m);
	
	unset( $tocHtml );
	
	$depth = 0;
	$inLink = false;
	$stack = array();
	$depthOffset = -1;
	$tmp = array();
	
	foreach ($m as $t) {
		$tag = $t[2];
		if ($t[1]=='' && !$inLink) ++$depth;
		if ($tag=='div' && preg_match('/class\s?=\s?"toc"/', $t[0]) && $depthOffset==-1)
			$depthOffset = $depth+1;
		
		if ($tag=='a') {
			$inLink = ($t[1]=='');
			if ($inLink) {
				preg_match( '/href\s?=\s?"([^"]*)/', $t[0], $m2 );
				$href = $m2[1];
			} else {
				$realDepth = $depth - $depthOffset;
				if ($realDepth < 0) $depthOffset -= $realDepth;  # should never happen
				$linkValue = trim( preg_replace( '/[\n\r\t\s]+/S', ' ', $linkValue ) );
				array_push($tmp, array(
					'depth' => $realDepth,
					'href'  => $href,
					'title' => $linkValue
				));
			}
			$linkValue = '';
		}
		if ($inLink) {
			if ($tag=='a') {
				$linkValue .= $t[3];
			} else {
				$linkValue .= preg_replace( '/<(\/?)([a-z0-9]+)([^>]*)>/', '<$1span$3>', $t[0] );
			}
		}
		if ($t[1]=='/' && !$inLink) --$depth;
	}
	
	$stack = array();
	$prevDepth = 0;
	$toc = array();
	
	foreach ($tmp as $arr) {
		$l = $prevDepth - $arr['depth'];
		if ($l >= 0) {
			for ($i=0; $i<=$l; ++$i) {
				array_pop($stack);
			}
		}
		
		$buildArr = '$toc';
		foreach ($stack as $s) {
			$buildArr.= '[\''. str_replace('\'', '\\\'', $s) .'\'][\'kids\']';
		}
		if (count($stack)>0)
			$parentHref = $stack[count($stack)-1];
		else
			$parentHref = '';
		$buildArr.= '[\''. $arr['href'] .'\']';
		eval( $buildArr .'[\'title\'] = \''. str_replace('\'', '\\\'', $arr['title']) .'\';');
		eval( $buildArr .'[\'href\'] = \''. $arr['href'] .'\';');
		eval( $buildArr .'[\'parent\'] = \''. $parentHref .'\';');
		eval( $buildArr .'[\'kids\'] = array();');
		
		array_push($stack, $arr['href']);
		$prevDepth = $arr['depth'];
	}
	
	
	
	preg_match( '/<h1[^>]*>([^<]+)<\/h1>/', $origTocHtml, $m);
	unset( $origTocHtml );
	$title = trim( @$m[1] );
	
	$toc = array(
		'title' => $title ? $title : 'Asterisk',
		'href'  => 'index.html',
		'parent'=> false,
		'kids'  => $toc
	);
	//print_r($toc);
	return $toc;
	
}


function kidsFromToc( $toc, $file='' ) {
	if ($file=='') return $toc;
	foreach ($toc['kids'] as $kidFile => $kid) {
		if ($kidFile == $file) return $kid;
	}
	foreach ($toc['kids'] as $kidFile => $kid) {
		$st = kidsFromToc( $kid, $file );
		if ($st) return $st;
	}
	return null;
}

function siblingsFromToc( $toc, $file ) {
	if ($file=='') return $toc;
	foreach ($toc['kids'] as $kidFile => $kid) {
		if ($kidFile == $file) return $toc;
	}
	foreach ($toc['kids'] as $kidFile => $kid) {
		$st = siblingsFromToc( $kid, $file );
		if ($st) return $st;
	}
	return null;
}

/*function parentFromToc( $toc, $file ) {
	if ($file=='') return $toc;
	foreach ($toc['kids'] as $kidFile => $kid) {
		if ($kidFile == $file) return $toc;
	}
	foreach ($toc['kids'] as $kidFile => $kid) {
		$st = parentFromToc( $kid, $file );
		if ($st) return $st;
	}
	return null;
}*/

function parentFromToc( $toc, $file ) {
	if ($file=='') return $toc;
	$self = kidsFromToc( $toc, $file );
	$parent = kidsFromToc( $toc, $self['parent'] );
	return $parent;
}

function selfFromToc( $toc, $file ) {
	if ($file=='') return $toc;
	$self = kidsFromToc( $toc, $file );
	return $self;
}

function parentOrSelfFromToc( $toc, $file ) {
	if (hasKids( $toc, $file ))
		return parentFromToc( $toc, $file );
	else
		return parentFromToc( $toc, $file );
}

function kidsOrSiblingsFromToc( $toc, $file ) {
	$st = kidsFromToc( $toc, $file );
	if ($st && is_array($st['kids']) && count($st['kids'])>0)
		return $st;
	else
		return parentFromToc( $toc, $file );
}

function hasKids( $toc, $file ) {
	$st = kidsFromToc( $toc, $file );
	return ($st && is_array($st['kids']) && count($st['kids'])>0);
}

function tocToHtml( $toc ) {
	$html = '<ul class="toc">'."\n";
	if ($toc) {
		foreach ($toc['kids'] as $kidFile => $kid) {
			$html.= '<li><a href="'. $kidFile .'">'. $kid['title'] .'</a></li>'."\n";
		}
	}
	$html.= '</ul>'."\n";
	return $html;
}

function buildHtmlToc( $toc, $file ) {
	$parent = parentFromToc( $toc, $file );
	$html = '&uarr; <b><a href="'. $parent['href'] .'">'. $parent['title'] .'</a></b><br /><br />'."\n";
	if (hasKids( $toc, $file )) {
		$self = selfFromToc( $toc, $file );
		$htmlSelf = '&uarr; <b><a href="'. $self['href'] .'">'. $self['title'] .'</a></b><br /><br />'."\n";
		if ($htmlSelf != $html) $html.= $htmlSelf;
	}
	$html.= tocToHtml( kidsOrSiblingsFromToc( $toc, $file ) );
	return $html;
}


//$toc = bookTocToStruct( './html/bk01-toc.html' );
//echo buildHtmlToc( $toc, 'applikationen-php.html' );


?>