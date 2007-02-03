

// Title: Tigra Hints
// URL: http://www.softcomplex.com/products/tigra_hints/
// Version: 1.4
// Date: 04/16/2006
// Note: Permission given to use this script in ANY kind of applications if
//    header lines are left unchanged.

var THintsS = [];
function THints (o_cfg, items) {
	this.n_id = THintsS.length;
	THintsS[this.n_id] = this;
	this.top = o_cfg.top ? o_cfg.top : 0;
	this.left = o_cfg.left ? o_cfg.left : 0;
	this.n_dl_show = o_cfg.show_delay;
	this.n_dl_hide = o_cfg.hide_delay;
	this.b_wise = o_cfg.wise;
	this.b_follow = o_cfg.follow;
	this.x = 0;
	this.y = 0;
	this.divs = [];
	this.iframes = [];
	this.show  = TTipShow;
	this.showD = TTipShowD;
	this.hide = TTipHide;
	this.move = TTipMove;
	// register the object in global collection
	this.n_id = THintsS.length;
	THintsS[this.n_id] = this;
	// filter Netscape 4.x out
	if (document.layers) return;
	var b_IE = navigator.userAgent.indexOf('MSIE') > -1,
	s_tag = ['<iframe frameborder="0" scrolling="No" id="TTifip%name%" style="visibility:hidden;position:absolute;top:0px;left:0px;',   b_IE ? 'width:1px;height:1px;' : '', o_cfg['z-index'] != null ? 'z-index:' + o_cfg['z-index'] : '', '" width=1 height=1></iframe><div id="TTip%name%" style="visibility:hidden;position:absolute;top:0px;left:0px;',   b_IE ? 'width:1px;height:1px;' : '', o_cfg['z-index'] != null ? 'z-index:' + o_cfg['z-index'] : '', '"><table cellpadding="0" cellspacing="0" border="0"><tr><td class="', o_cfg.css, '">%text%</td></tr></table></div>'].join('');


	this.getElem = 
		function (id) { return document.all ? document.all[id] : document.getElementById(id); };
	this.showElem = 
		function (id, hide) { 
		this.divs[id].o_css.visibility = hide ? 'hidden' : 'visible'; 
		this.iframes[id].o_css.visibility = hide ? 'hidden' : 'visible'; 
		};
	
	document.onmousemove = f_onMouseMove;
	if (window.opera)
		this.getSize = function (id, b_hight) { 
			return this.divs[id].o_css[b_hight ? 'pixelHeight' : 'pixelWidth']
		};
	else
		this.getSize = function (id, b_hight) { 
			return this.divs[id].o_obj[b_hight ? 'offsetHeight' : 'offsetWidth'] 
		};
	for (i in items) {
		//document.write (s_tag.replace(/%text%/g, items[i]).replace(/%name%/g, i));
		
		var el = document.createElement('div');
		el.innerHTML = s_tag.replace(/%text%/g, items[i]).replace(/%name%/g, i);
		document.documentElement.appendChild(el);
		
		this.divs[i] = { 'o_obj' : this.getElem('TTip' + i) };
		this.divs[i].o_css = this.divs[i].o_obj.style;
		this.iframes[i] = { 'o_obj' : this.getElem('TTifip' + i) };
		this.iframes[i].o_css = this.iframes[i].o_obj.style;
		
	}
}
function TTipShow (id) {
	if (document.layers) return;
	this.hide();
	if (this.divs[id]) {
		if (this.n_dl_show) this.divs[id].timer = setTimeout('THintsS[' + this.n_id + '].showD("' + id + '")', this.n_dl_show);
		else this.showD(id);
		this.visible = id;
	}
}

function TTipShowD (id) {
	this.move(id);
	this.showElem(id);
	if (this.n_dl_hide) this.timer = setTimeout("THintsS[" + this.n_id + "].hide()", this.n_dl_hide);
}

function TTipMove (id) {
	var	n_win_l = f_scrollLeft(),
		n_win_t = f_scrollTop();

	var n_x = window.n_mouseX + n_win_l + this.left,
		n_y = window.n_mouseY + n_win_t + this.top;
		
	window.status = n_x;
	if (this.b_wise) {
		var n_w = this.getSize(id), n_h = this.getSize(id, true),
		n_win_w = f_clientWidth(), n_win_h = f_clientHeight();

		if (n_x + n_w > n_win_w + n_win_l) n_x = n_win_w + n_win_l - n_w;
		if (n_x < n_win_l) n_x = n_win_l;
		if (n_y + n_h > n_win_h + n_win_t) n_y = n_win_h + n_win_t - n_h;
		if (n_y < n_win_t) n_y = n_win_t;
	}
	this.divs[id].o_css.left = n_x + 'px';
	this.divs[id].o_css.top = n_y + 'px';
	this.iframes[id].o_css.left = n_x + 'px';
	this.iframes[id].o_css.top = n_y + 'px';
	this.iframes[id].o_css.height = (n_h-this.top) + 'px';
	this.iframes[id].o_css.width = (this.getSize(id, false)-this.left) + 'px';
}

function TTipHide () {
	if (this.timer) clearTimeout(this.timer);
	if (this.visible != null) {
		if (this.divs[this.visible].timer) clearTimeout(this.divs[this.visible].timer);
		setTimeout('THintsS[' + this.n_id + '].showElem("' + this.visible + '", true)', 10);
		this.visible = null;
	}
}

function f_onMouseMove(e_event) {
	if (!e_event && window.event) e_event = window.event;
	if (e_event) {
		window.n_mouseX = e_event.clientX;
		window.n_mouseY = e_event.clientY;
	}
	return true;
}
function f_clientWidth() {
	if (typeof(window.innerWidth) == 'number')
		return window.innerWidth;
	if (document.documentElement && document.documentElement.clientWidth)
		return document.documentElement.clientWidth;
	if (document.body && document.body.clientWidth)
		return document.body.clientWidth;
	return null;
}
function f_clientHeight() {
	if (typeof(window.innerHeight) == 'number')
		return window.innerHeight;
	if (document.documentElement && document.documentElement.clientHeight)
		return document.documentElement.clientHeight;
	if (document.body && document.body.clientHeight)
		return document.body.clientHeight;
	return null;
}
function f_scrollLeft() {
	if (typeof(window.pageXOffset) == 'number')
		return window.pageXOffset;
	if (document.body && document.body.scrollLeft)
		return document.body.scrollLeft;
	if (document.documentElement && document.documentElement.scrollLeft)
		return document.documentElement.scrollLeft;
	return 0;
}
function f_scrollTop() {
	if (typeof(window.pageYOffset) == 'number')
		return window.pageYOffset;
	if (document.body && document.body.scrollTop)
		return document.body.scrollTop;
	if (document.documentElement && document.documentElement.scrollTop)
		return document.documentElement.scrollTop;
	return 0;
}





function wrapHint( html ) {
	return '<div class="" style="max-width:500px; background:#fff; opacity:0.9; -moz-opacity:0.9; filter:progid:DXImageTransform.Microsoft.dropShadow(Color=#777777,offX=4,offY=4); border:1px solid #000; padding:0.5em 0.7em 0.1em 0.7em;">'+ html +'</div>';
}


var HINTS_CFG = {
	'top'        : 5, // a vertical offset of a hint from mouse pointer
	'left'       : 5, // a horizontal offset of a hint from mouse pointer
	'css'        : 'hintsClass', // a style class name for all hints, TD object
	'show_delay' : 250, // a delay between object mouseover and hint appearing
	'hide_delay' : 8000, // a delay between hint appearing and hint hiding
	'wise'       : true,
	'follow'     : true,
	'z-index'    : 200 // a z-index for all hint layers
};

var HINTS_ITEMS = {};

var myHints = null;

function initFootnotes() {
	var links = document.getElementsByTagName('a');
	var href = '';
	for (var i=0; i<links.length; ++i) {
		if (links[i].tagName.toUpperCase()=='A') {
			href = links[i].getAttribute('href');
			if (href && href.substr(0,5)=='#ftn.') {
				try {
					var ftn = document.getElementById( 'ftn.'+ links[i].id );
					while (ftn.className.indexOf('footnote')==-1) {
						ftn = ftn.parentNode;
					}
					
					HINTS_ITEMS[ftn.id] = wrapHint( ftn.innerHTML );
					
					links[i].setAttribute('onmouseover', 'myHints.show("'+ftn.id+'");');
					links[i].setAttribute('onmouseout', 'myHints.hide();');
					
					
				} catch(e) {}
			}
		}
	}
	myHints = new THints (HINTS_CFG, HINTS_ITEMS);
}



window.onload = initFootnotes;









var TRACKVP_CONF = {
	'interval'   : 2000, // milliseconds. good start: 1000
	'startdelay' : 10,   // seconds. good start: 10
	'reqscroll'  : true, // require that the page be scroll before counting starts
	'threshold'  : 0.4,  // threshold for an element's "weight" to count
	'minviewtime': 15,   // seconds. good start: 10
	'debug'      : false // show debug info
};


var trackvp_monitoredElements = [];
var trackvp_monitorElementsWindowWasScrolled = false;
var trackvp_cycle = 0;
var trackvp_currentEl = null;
var trackvp_hitCache = {};

function trackvp_monitorElements( list ) {
	if ((typeof list) != 'object') return;
	var elements = [];
	for (var i=list.length-1; i>=0; --i) {
		try {
			var el   = list[i]['element'];
			var name = list[i]['name'];
			if (el && name && el.tagName) elements.push({
				'el'  : el,
				'name': name
			});
		} catch(e){}
	}
	trackvp_monitoredElements = elements;
	
	if (TRACKVP_CONF['debug']) {
		var debug = document.createElement('div');
		debug.id = 'monitorElementsDebug';
		debug.setAttribute('style', 'display:block; position:fixed; right:7px; top:5px; width:300px; z-index:200; border:3px solid #666; background:#fff; opacity:0.9; -moz-opacity:0.9; font-family:Verdana,Arial,Helvetica,sans-serif; font-size:11px; font-weight:normal; line-height:1em; padding:5px 8px 7px 8px;');
		debug.innerHTML = '&nbsp;';
		document.documentElement.appendChild( debug );
	}
	
	// consider n consecutive "views" (see trackvp_monitorElementsUpdate())
	// a hit:
	TRACKVP_CONF['_inarow'] =
		Math.round( TRACKVP_CONF['minviewtime'] / (TRACKVP_CONF['interval']/1000) );
	if (TRACKVP_CONF['_inarow'] < 1) TRACKVP_CONF['_inarow'] = 1;
	
	window.onscroll = function(){
		window.setTimeout( function(){window.onscroll = null;}, 10 );
		trackvp_monitorElementsWindowWasScrolled = true;
	};
	
	window.setTimeout(
		trackvp_monitorElementsUpdate,
		TRACKVP_CONF['startdelay']*1000 );
}

function trackvp_monitorElementsUpdate() {
	if (TRACKVP_CONF['reqscroll']
	&& ! trackvp_monitorElementsWindowWasScrolled) {
		window.setTimeout(
			trackvp_monitorElementsUpdate,
			TRACKVP_CONF['interval'] );
		return;
	}
	
	var visibleElements = [];
	var visibleElement = null;
	for (var i=trackvp_monitoredElements.length-1; i>=0; --i) {
		try {
			var pctY = trackvp_elementInViewportY( trackvp_monitoredElements[i]['el'] );
			if (pctY > 0) {
				trackvp_monitoredElements[i]['pct'] = pctY;
				visibleElements.push( trackvp_monitoredElements[i] );
				if (pctY > TRACKVP_CONF['threshold']) {
					if (! visibleElement
					|| (visibleElement && pctY > visibleElement['pct'])) {
						visibleElement  = trackvp_monitoredElements[i];
					}
				}
			}
		} catch(e){}
	}
	
	if (TRACKVP_CONF['debug']) {
		var debug = document.getElementById('monitorElementsDebug');
		var debugVis = '';
		for (var i=visibleElements.length-1; i>=0; --i) {
			debugVis += 'Visible: '+ visibleElements[i]['name'] +' ('+ visibleElements[i]['pct'] +')<br />';
		}
		if (visibleElement)
			debugVis += 'Best match: <b>'+ visibleElement['name'] +'</b><br />'
		if (debugVis != '')
			debug.innerHTML = debugVis;
		else
			debug.innerHTML = '<i style="color:#666;">(no monitored elements in viewport)</i>';
	}
	
	if (! visibleElement) {
		trackvp_currentEl = null;
		trackvp_cycle = 0;
	} else {
		if (! trackvp_currentEl) {
			trackvp_currentEl = visibleElement;
			trackvp_cycle = 0;
		} else {
			if (visibleElement['name'] != trackvp_currentEl['name']) {
				trackvp_currentEl = visibleElement;
				trackvp_cycle = 0;
			} else {
				if (trackvp_cycle < TRACKVP_CONF['_inarow']) {
					++trackvp_cycle;
				} else {
					if (! trackvp_hitCache[trackvp_currentEl['name']]) {
						trackvp_hitCache[trackvp_currentEl['name']] = true;
						if (TRACKVP_CONF['debug'])
							trackvp_flashDebug();
						trackvp_hit();
					}
					trackvp_currentEl = null;
					trackvp_cycle = 0;
				}
			}
		}
	}
	
	window.setTimeout( trackvp_monitorElementsUpdate, TRACKVP_CONF['interval'] );
}

function trackvp_flashDebug() {
	document.getElementById('monitorElementsDebug').style.backgroundColor = '#0f0';
	window.setTimeout( function() {
		document.getElementById('monitorElementsDebug').style.backgroundColor = '#fff';
		}, 200 );
}

function trackvp_hit() {
	var iframe = document.getElementById('trackvm_iframe');
	if (! iframe) {
		var iframe = document.createElement('iframe');
		iframe.id = 'trackvm_iframe';
		iframe.setAttribute('style', 'display:block; position:absolute; left:1px; top:1px; width:4px; height:4px; border:0; opacity:0.4; -moz-opacity:0.4; background:#fff; padding:0; margin:0; overflow:hidden;');
		document.documentElement.appendChild( iframe );
	}
	iframe.setAttribute('src', 'trackvp/trackvp-'+ trackvp_currentEl['name'] +'.html');
}

function trackvp_elementInViewportY( el ) {
	if (! el || ! el.tagName) return 0;
	/*
	el.offsetTop
	el.offsetHeight
	window.scrollY
	window.innerHeight
	*/
	
	var viewportEndY = window.scrollY + window.innerHeight;
	
	// element below the viewport?
	if (el.offsetTop > viewportEndY) return 0;
	
	var elementEndY = el.offsetTop + el.offsetHeight;
	
	// element above of the viewport?
	if (elementEndY < window.scrollY) return 0;
	
	// starts above viewport and ends below?
	if (el.offsetTop < window.scrollY && elementEndY > viewportEndY)
		return 1;
	
	var startsInViewport = (
		el.offsetTop > window.scrollY &&
		el.offsetTop < window.scrollY + window.innerHeight - 5
	);
	var endsInViewport = (
		elementEndY > window.scrollY &&
		elementEndY < window.scrollY + window.innerHeight - 5
	);
	
	var elementFactor = window.innerHeight / el.offsetHeight;
	if (elementFactor < 1) elementFactor = 1;
	// to compensate for elements smaller than the viewport
	
	// starts in viewport and ends below?
	if (startsInViewport && ! endsInViewport) {
		var weight = round((1 - ((el.offsetTop - window.scrollY) / window.innerHeight)) * elementFactor *0.9, 100);
		// *0.9 to give elements at the lower edge slightly less weight
		// compared to elements in the middle of the viewport
		if (weight > 0.9) weight = 0.9;  // just to be on the safe side
		return weight;
	}
	
	// starts above and ends in viewport?
	if (endsInViewport && ! startsInViewport) {
		var weight = round((1 - ((viewportEndY - elementEndY) / window.innerHeight)) * elementFactor *0.9, 100);
		// *0.9 to give elements at the upper edge slightly less weight
		// compared to elements in the middle of the viewport
		if (weight > 0.9) weight = 0.9;  // just to be on the safe side
		return weight;
	}
	
	// starts and ends in viewport?
	if (startsInViewport && endsInViewport)
		return 1;
	
	return 0.05;  // unknown
}

function round( floatVal, div ) {
	div = div || 1;
	return Math.round( floatVal * div ) / div;
}







function getDocbookSectionByAnchor( id ) {
	var el = document.getElementById( id );
	if (el) {
		while (el.className.indexOf('section')==-1) {
			el = el.parentNode;
		}
		return el;
	} else
		return null;
}

function myInitMonitoredElements() {
	var sections = [
		'installation-1.2-debian',
		'installation-1.2-fedora',
		'installation-1.2-freebsd',
		'installation-1.2-macosx',
		'installation-1.2-opensuse',
		'installation-1.2-ubuntu',
		'installation-1.4-asterisknow',
		'installation-1.4-debian',
		'installation-1.4-fedora',
		'installation-1.4-macosx',
		'installation-1.4-ubuntu'
	];
	var elements = [];
	for (var i=sections.length-1; i>=0; --i) {
		try {
			var el = getDocbookSectionByAnchor( sections[i] );
			if (el) elements.push({
				'element': el,
				'name'   : sections[i]
			});
		} catch(e){}
	}
	if (elements.length > 0)
		trackvp_monitorElements( elements );
}

window.addEventListener( 'load', myInitMonitoredElements, false );

