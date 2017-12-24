//================================================================
// Bookmark Favicon Changer by Sonthakit Leelahanon.
// Copyright 2014 Sonthakit Leelahanon. All rights reserved.
//================================================================
"use strict";


var title = "";
var faviconDataURL = "";
var shortcutURL = "";
var backgroundWin = null;


document.addEventListener("DOMContentLoaded", function() {
	backgroundWin = window.top.backgroundWin;
	document.getElementById("targetURL").addEventListener("input", function(event) {
		document.getElementById("createShortcut").setAttribute("disabled", "disabled");
	});
	document.getElementById("bookmarkName").addEventListener("input", function(event) {
		document.getElementById("createShortcut").setAttribute("disabled", "disabled");
	});
	document.getElementById("openFile").addEventListener("change", function(event) {
		var imageFile = event.target.files[0];
		var reader = new FileReader();
		reader.addEventListener("abort", function(event) {
			faviconDataURL = "";
			document.getElementById("selectFaviconImage").src = "";
			document.getElementById("openFile").value = "";
			alert("Error - file reader abort");
		});
		reader.addEventListener("error", function(event) {
			faviconDataURL = "";
			document.getElementById("selectFaviconImage").src = "";
			document.getElementById("openFile").value = "";
			alert("Error - file reader error");
		});
		reader.addEventListener("loadend", function(event) {
			var img = new Image();
			img.addEventListener("abort", function(event) {
				faviconDataURL = "";
				document.getElementById("selectFaviconImage").src = "";
				document.getElementById("openFile").value = "";
				alert("Error - image loader abort");
			});
			img.addEventListener("error", function(event) {
				faviconDataURL = "";
				document.getElementById("selectFaviconImage").src = "";
				document.getElementById("openFile").value = "";
				alert("Error - image loader error");
			});
			img.addEventListener("load", function(event) {
				faviconDataURL = backgroundWin.changeImageToDataURL(event.target);
				document.getElementById("selectFaviconImage").src = faviconDataURL;
			});
			var imageDataURL = backgroundWin.ico16x16Resolution(event.target.result);
			img.src = imageDataURL;
		});
		reader.readAsDataURL(imageFile);
		document.getElementById("createShortcut").setAttribute("disabled", "disabled");
	});
	document.getElementById("testShortcut").addEventListener("click", function(event) {
		var targetURL = document.getElementById("targetURL").value;
		targetURL = targetURL.replace(/^\s+|\s+$/g, "");
		if ((targetURL.indexOf("\r")!== -1) || (targetURL.indexOf("\n")!== -1)) {
			alert('Invalid character in URL ["LF" (U+000A) or "CR" (U+000D) characters]');
		} else {
			targetURL = encodeURI(targetURL);
			if (faviconDataURL === "") {
				alert("You don't select any favicon");
			} else {
				title = document.getElementById("bookmarkName").value;
				title = title.replace(/^\s+|\s+$/g, "");
				var inner = '<html><head>'
				if (title !== "") {
					inner += '<title></title>';
				}
				inner += '<link rel="icon" href="' + faviconDataURL + '" type="image/png" /></head><body><script>';
				if (title !== "") {
					var titleUTF8 = window.btoa(unescape(encodeURIComponent(title)));
					inner += 'document.getElementsByTagName("title")[0].innerHTML = decodeURIComponent(escape(window.atob("' + titleUTF8 + '")));';
				}
				inner += 'window.location.href="' + targetURL +'";</script></body></html>';
				shortcutURL = "data:text/html;base64," + window.btoa(inner);
				chrome.windows.create({url: shortcutURL, focused: false, incognito:false, type:"normal"}, function(result) {
					document.getElementById("createShortcut").removeAttribute("disabled");
				});
			}
		}
	});
	document.getElementById("createShortcut").addEventListener("click", function(event) {
		if (document.getElementById("barFirst").checked) {
			var dataObject = {parentId:backgroundWin.bookmarkBarId, index:0, title:title, url:shortcutURL};
		} else if (document.getElementById("barLast").checked) {
			var dataObject = {parentId:backgroundWin.bookmarkBarId, title:title, url:shortcutURL};
		} else if (document.getElementById("otherFirst").checked) {
			var dataObject = {index:0, title:title, url:shortcutURL};
		} else if (document.getElementById("otherLast").checked) {
			var dataObject = {title:title, url:shortcutURL};
		}
		chrome.bookmarks.create(dataObject, function(result) {
			if (!result) {
				backgroundWin.bannedWatch();
				window.top.logWin.log("red", "Error create bookmark");
			} else {
				chrome.tabs.create({url:result.url, active:true});
			}
		});
	});
});
