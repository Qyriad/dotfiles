//================================================================
// Bookmark Favicon Changer by Sonthakit Leelahanon.
// Copyright 2014 Sonthakit Leelahanon. All rights reserved.
//================================================================
"use strict";


function show(what) {
	document.body.setAttribute("data-show", what);
	window.scrollTo(0, document.body.scrollHeight);
}
function clearLog() {
	while (document.body.hasChildNodes()) {
		document.body.removeChild(document.body.lastChild);
	}
}
function log(color, logText) {
	var font = document.createElement("font");
	font.style.fontSize = "small";
	font.style.color = color;
	font.setAttribute("class", color);
	font.appendChild(document.createTextNode(logText));
	document.body.appendChild(font);
	var br = document.createElement("br")
	br.setAttribute("class", color);
	document.body.appendChild(br);
	window.scrollTo(0, document.body.scrollHeight);
}
document.addEventListener("DOMContentLoaded", function() {
	window.top.logWin = window;
	window.addEventListener("keyup", function(event) {
		if (event.keyCode === 46) {
			try {
				window.top.bookmarkWin.deleteBookmark();
			} catch(e) {
			}
		}
	});
});
