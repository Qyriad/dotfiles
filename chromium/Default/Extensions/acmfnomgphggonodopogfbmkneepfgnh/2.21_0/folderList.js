//================================================================
// Bookmark Favicon Changer by Sonthakit Leelahanon.
// Copyright 2014 Sonthakit Leelahanon. All rights reserved.
//================================================================
"use strict";


var minus = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAOElEQVQ4T2NkoBAwUqifYRga8J+EMAF7Hz0MQAYQEy5wdcPcAGwBCvPySAkDfGkKbxgQmxjBAQoAYZcVEUcARysAAAAASUVORK5CYII=";
var plus = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAASUlEQVQ4T2NkoBAwUqifYRga8J+EMAF7Hz0MQAYQEy5wdXQxAJurSHIB2QZgC1CYl+njAliMku0FfEmCJC9gMwivAcQmRnCAAgDp0hkRj0SCGAAAAABJRU5ErkJggg==";
var currentFolderId = null;
var backgroundWin = null;


//================================================
// Folder Command
//================================================
var expandCommand = null;
function addFolder(bookmarkTreeNode, depth, parentDivId) {
	var folderId = bookmarkTreeNode.id;
	var title = bookmarkTreeNode.title;
	if (bookmarkTreeNode.parentId === backgroundWin.bookmarkBarId) {
		if (backgroundWin.autoHideBookmarkBarName) {
			var i = backgroundWin.bookmarkBarName.id.indexOf(folderId);
			if (i !== -1) {
				title = decodeURIComponent(escape(window.atob(backgroundWin.bookmarkBarName.title[i])));
			}
		}
	}
	var div = document.createElement("div");
	div.id = "div-" + folderId;
	div.setAttribute("class", "folder");
	div.style.margin = "0px 0px 0px " + (depth * 13).toString() + "px";
	div.addEventListener("click", function(event) { nodeClick(event); });
	div.addEventListener("dblclick", function(event) { signEvent(event); });
	var sign = document.createElement("img");
	sign.id = "sign-" + folderId;
	sign.src = backgroundWin.nullPNG;
	var childs = bookmarkTreeNode.children;
	if (childs) {
		for (var i=0; i < childs.length; i++) {
			if (!childs[i].url) {
				sign.src = plus;
				break;
			}
		}
	}
	sign.addEventListener("click", function(event) { signEvent(event); });
	div.appendChild(sign);
	var img = document.createElement("img");
	img.src = "folderClose.png";
	img.id = "img-" + folderId;
	div.appendChild(img);
	var font = document.createElement("font");
	font.id = "font-" + folderId;
	font.appendChild(document.createTextNode(title));
	div.appendChild(font);
	div.addEventListener("dragover", function(event) { dragOver(event); });
	div.addEventListener("drop", function(event) { drop(event); });
	var divTree = document.createElement("div");
	divTree.id = "divTree-" + folderId;
	divTree.setAttribute("data-depth", depth);
	divTree.appendChild(div);
	document.getElementById(parentDivId).appendChild(divTree);
}
function addCommand(folderToExpand) {
	if (folderToExpand === backgroundWin.bookmarkRootId) {
		executeCommand();
	} else {
		var i = expandCommand.indexOf(folderToExpand);
		if (i !== -1) {
			executeCommand();
		} else {
			expandCommand.push(folderToExpand);
			chrome.bookmarks.get(folderToExpand, function(results) {
				addCommand(results[0].parentId);
			});
		}
	}
}
function executeCommand() {
	if (expandCommand.length === 0) {
		folderClick(window.top.targetFolder);
	} else {
		var fonts = document.getElementsByTagName("font");
		for (var i=0; i < fonts.length; i++) {
			if (fonts[i].id.indexOf("-") !== -1) {
				var j = expandCommand.indexOf(fonts[i].id.split("-")[1]);
				if (j !== -1) {
					var expandAt = expandCommand[j];
					expandCommand.splice(j, 1);
					signClick(expandAt);
					return;
				}
			}
		}
		expandCommand = [];
		folderClick(window.top.targetFolder);
	}
}


//================================================
// Click function
//================================================
function nodeClick(event) {
	folderClick(event.target.id.split("-")[1]);
}
function folderClick(folderId) {
	try {
		document.getElementById("div-" + currentFolderId).removeAttribute("data-current");
		document.getElementById("img-" + currentFolderId).src = "folderClose.png";
	} catch(e) {
	}
	chrome.bookmarks.get(folderId, function(results) {
		if (results) {
			window.top.targetFolder = results[0].id;
			currentFolderId = results[0].id;
		} else {
			window.top.targetFolder = backgroundWin.bookmarkBarId;
			currentFolderId = backgroundWin.bookmarkBarId;
		}
		document.getElementById("div-" + currentFolderId).setAttribute("data-current", true);
		document.getElementById("img-" + currentFolderId).src = "folderOpen.png";
		if (document.getElementById("sign-" + currentFolderId).src === "plus") {
			signClick(currentFolderId);
		}
		if (parent.document.getElementById("bookmarkList").src === "bookmarkList.xhtml") {
			if (window.top.bookmarkWin) {
				if (currentFolderId === window.top.bookmarkWin.currentFolderId) {
					return;
				}
			}
		}
		parent.document.getElementById("bookmarkList").src = "bookmarkList.xhtml";
	});
}
function signEvent(event) {
	event.stopPropagation();
	signClick(event.target.id.split("-")[1]);
}
function signClick(folderId) {
	var sign = document.getElementById("sign-" + folderId);
	if (sign.src === plus) {
		sign.src = minus;
		var parentId = folderId;
		var depth = Number(document.getElementById("divTree-" + folderId).getAttribute("data-depth")) + 1;
		(function(parentId, depth) {
			chrome.bookmarks.getSubTree(parentId, function(results) {
				var childs = results[0].children;
				for (var i=0; i < childs.length; i++) {
					if (!childs[i].url) {
						addFolder(childs[i], depth, "divTree-" + results[0].id);
					}
				}
				executeCommand();
			});
		})(parentId, depth);
	} else if (sign.src === minus) {
		sign.src = plus;
		var divTree = document.getElementById("divTree-" + folderId);
		if (divTree.hasChildNodes()) {
			while (divTree.lastChild.id !== ("div-" + folderId)) {
				divTree.removeChild(divTree.lastChild);
			}
		}
		var fonts = document.getElementsByTagName("font");
		var targetCurrentFolder = folderId;
		for (var i=0; i < fonts.length; i++) {
			if (fonts[i].id.indexOf("-") !== -1) {
				if (currentFolderId === fonts[i].id.split("-")[1]) {
					targetCurrentFolder = currentFolderId;
					break;
				}
			}
		}
		folderClick(targetCurrentFolder);
	}
	window.top.expandFolder = [];
	var fonts = document.getElementsByTagName("font");
	for (var i=0; i < fonts.length; i++) {
		if (fonts[i].id.indexOf("-") !== -1) {
			var rowId = fonts[i].id.split("-")[1];
			var sign = document.getElementById("sign-" + rowId);
			if (sign.src === minus) {
				window.top.expandFolder.push(rowId);
			}
		}
	}
}


//================================================
// Drag Drop
//================================================
function dragOver(event) {
	event.stopPropagation();
	var folderId =  event.target.id.split("-")[1];
	if (folderId !== currentFolderId) {
		if (window.top.bookmarkWin.canDrop(folderId)) {
			event.preventDefault();
		}
	}
}
function drop(event) {
	event.stopPropagation();
	event.preventDefault();
	var rowId = event.target.id.split("-")[1];
	if (window.top.bookmarkWin.canDrop(rowId)) {
		window.top.bookmarkWin.dropInFolder(rowId);
	}
}


//================================================
// Begin here
//================================================
document.addEventListener("DOMContentLoaded", function() {
	window.top.folderWin = window;
	backgroundWin = window.top.backgroundWin;
	chrome.bookmarks.getTree(function(results) {
		var childs = results[0].children;
		for (var i=0; i < childs.length; i++) {
			if (!childs[i].url) {
				addFolder(childs[i], 0, "0");
			}
		}
		expandCommand = window.top.expandFolder;
		chrome.bookmarks.get(window.top.targetFolder, function(results) {
			if (results) {
				if (results[0].url) {
					window.top.targetFolder = results[0].parentId;
					window.top.targetBookmark = results[0].id;
				} else if (results[0].id === backgroundWin.bookmarkRootId) {
					window.top.targetFolder = backgroundWin.bookmarkBarId;
					window.top.targetBookmark = "0";
				} else {
					window.top.targetFolder = results[0].id;
					window.top.targetBookmark = "0";
				}
			} else {
				window.top.targetFolder = backgroundWin.bookmarkBarId;
				window.top.targetBookmark = "0";
			}
			chrome.bookmarks.get(window.top.targetFolder, function(results) {
				addCommand(results[0].parentId);
				window.addEventListener("keyup", function(event) {
					if (event.keyCode === 46) {
						try {
							window.top.bookmarkWin.deleteBookmark();
						} catch(e) {
						}
					}
				});
			});
		});
	});
});
