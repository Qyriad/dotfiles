//================================================================
// Bookmark Favicon Changer by Sonthakit Leelahanon.
// Copyright 2014 Sonthakit Leelahanon. All rights reserved.
//================================================================
"use strict";


var backgroundWin = null;


//================================================
// Reset All Non Custom Favicon Bookmark
//================================================
function recursiveResetAllNonCustomBookmark(bookmarkTreeNodes) {
	for (var i=0; i < bookmarkTreeNodes.length; i++) {
		var bookmarkTreeNodeId = bookmarkTreeNodes[i].id;
		var bookmarkTreeNodeURL = bookmarkTreeNodes[i].url;
		if (bookmarkTreeNodeURL) {
			if (backgroundWin.isUsableURL(bookmarkTreeNodeURL)) {
				if (backgroundWin.data.pageURL.indexOf(bookmarkTreeNodeURL) === -1) {
					window.top.resetFavicon(bookmarkTreeNodeURL);
				}
			}
		} else {
			if (bookmarkTreeNodes[i].children) {
				if (bookmarkTreeNodes[i].children.length !== 0) {
					recursiveResetAllNonCustomBookmark(bookmarkTreeNodes[i].children);
				}
			}
		}
	}
}


//================================================
// Begin here
//================================================
document.addEventListener("DOMContentLoaded", function() {
	backgroundWin = window.top.backgroundWin;
	document.getElementById("viewDatabase").addEventListener("click", function(event) {
		chrome.windows.create({url:"viewDatabase.xhtml", width:400, height: 300, focused: true, incognito:false, type:"popup"})
	});
	document.getElementById("restoreLost").addEventListener("click", function(event) {
		for (var i=0; i < backgroundWin.data.pageURL.length; i++) {
			window.top.changeFavicon(backgroundWin.data.pageURL[i], backgroundWin.data.pageCustomFavicon[i], backgroundWin.data.pageOriginalFavicon[i]);
		}
	});
	document.getElementById("resetAllNonCustom").addEventListener("click", function(event) {
		chrome.bookmarks.getTree(function(results) {
			recursiveResetAllNonCustomBookmark(results[0].children);
		});
	});
	document.getElementById("exportAll").addEventListener("click", function(event) {
		if (!window.top.exportActive) {
			if ((backgroundWin.data.pageURL.length + backgroundWin.tabIconRule.length) === 0) {
				alert("Neither custom favicon nor tab icon is found.");
			} else {
				var pageURLs = backgroundWin.data.pageURL.slice();
				var tabIcons = [];
				for (var i=0; i < backgroundWin.tabIconRule.length; i++) {
					tabIcons.push(backgroundWin.tabIconRule[i].tabIconURL);
				}
				window.top.exportMultipleFavicon(pageURLs, tabIcons);
			}
		}
	});
	document.getElementById("importPageCustomFaviconDatabase").addEventListener("click", function(event) {
		if (!window.top.importActive) {
			document.getElementById("importPageCustomFaviconDatabaseInput").value = "";
			document.getElementById("importPageCustomFaviconDatabaseInput").click();
		}
	});
	document.getElementById("importPageCustomFaviconDatabaseInput").addEventListener("change", function(event) {
		var importFile = event.target.files[0];
		window.top.logWin.log("black", "Import custom favicon database");
		var reader = new FileReader();
		reader.addEventListener("abort", function(event) {
			window.top.logWin.log("red", "Error - Import file reading abort.");
		});
		reader.addEventListener("error", function(event) {
			window.top.logWin.log("red", "Error - Import file reading error.");
		});
		reader.addEventListener("loadend", function(event) {
			var importDataText = event.target.result;
			window.top.mergeImport(importDataText);
		});
		reader.readAsText(importFile, "UTF-8");
	});
	document.getElementById("exportPageCustomFaviconDatabase").addEventListener("click", function(event) {
		window.top.exportDatabase();
	});
	document.getElementById("resetAllCustom").addEventListener("click", function(event) {
		if (confirm("Are you sure to delete all data in database?")) {
			for (var i=0; i < backgroundWin.data.pageURL.length; i++) {
				window.top.resetFavicon(backgroundWin.data.pageURL[i]);
			}
		}
	});
});
