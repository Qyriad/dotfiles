//================================================================
// Bookmark Favicon Changer by Sonthakit Leelahanon.
// Copyright 2014 Sonthakit Leelahanon. All rights reserved.
//================================================================
"use strict";


var currentFolderId = null;
var backgroundWin = null;


//================================================
// General function
//================================================
function resizeContent() {
	var root = document.getElementById("0");
	var rect = root.getBoundingClientRect();
	var newWidth = window.innerWidth - rect.left;
	var newHeight = window.innerHeight - rect.top;
	root.style.width = newWidth.toString() + "px";
	root.style.height = newHeight.toString() + "px";
}
function getAllRowIds() {
	var allRowIds = [];
	var divs = document.getElementsByTagName("div");
	for (var i=0; i < divs.length; i++) {
		if (divs[i].id.indexOf("-") !== -1) {
			allRowIds.push(divs[i].id.split("-")[1]);
		}
	}
	return allRowIds;
}
function getSelectedRowIds() {
	var selectedRowIds = [];
	var divs = document.getElementsByTagName("div");
	for (var i=0; i < divs.length; i++) {
		if (divs[i].id.indexOf("-") !== -1) {
			if (divs[i].hasAttribute("data-selected")) {
				selectedRowIds.push(divs[i].id.split("-")[1]);
			}
		}
	}
	return selectedRowIds;
}
function getSelectedURLs() {
	var selectedURLs = [];
	var divs = document.getElementsByTagName("div");
	for (var i=0; i < divs.length; i++) {
		if (divs[i].id.indexOf("-") !== -1) {
			if (divs[i].hasAttribute("data-selected")) {
				if (divs[i].hasAttribute("title")) {
					selectedURLs.push(divs[i].getAttribute("title"));
				}
			}
		}
	}
	return selectedURLs;
}
function addRow(bookmarkNode) {
	var root = document.getElementById("0");
	var last = document.getElementById("lastRow");
	var div = document.createElement("div");
	div.id = "div-" + bookmarkNode.id;
	div.setAttribute("class", "divRow");
	var checkBox = document.createElement("input");
	checkBox.id = "checkBox-" + bookmarkNode.id;
	checkBox.setAttribute("type", "checkbox");
	var img = document.createElement("img");
	img.id = "img-" + bookmarkNode.id;
	img.setAttribute("class", "favicon");
	var font = document.createElement("font");
	font.id = "font-" + bookmarkNode.id;
	font.setAttribute("class", "fontURL");
	var fontEdit = document.createElement("font");
	fontEdit.id = "fontEdit-" + bookmarkNode.id;
	var bookmarkNodeTitle = bookmarkNode.title;
	if (currentFolderId === backgroundWin.bookmarkBarId) {
		if (backgroundWin.autoHideBookmarkBarName) {
			var i = backgroundWin.bookmarkBarName.id.indexOf(bookmarkNode.id);
			if (i !== -1) {
				bookmarkNodeTitle = decodeURIComponent(escape(window.atob(backgroundWin.bookmarkBarName.title[i])));
			}
		}
	}
	fontEdit.setAttribute("data-bookmarkTitle", bookmarkNodeTitle);
	fontEdit.setAttribute("class", "fontEdit");
	fontEdit.appendChild(document.createTextNode(" " + bookmarkNodeTitle));
	if (bookmarkNode.url) {
		img.src = backgroundWin.getChromeFaviconURL(bookmarkNode.url);
		font.appendChild(document.createTextNode(bookmarkNode.url));
		div.setAttribute("title", bookmarkNode.url);
	} else {
		img.src = "folderClose.png";
		div.addEventListener("dblclick", function(event) { nodeDblClick(event); });
	}
	div.appendChild(checkBox);
	div.appendChild(img);
	div.appendChild(fontEdit);
	div.appendChild(font);
	div.addEventListener("click", function(event) { nodeClick(event); });
	div.addEventListener("dragstart", function(event) { dragStart(event); });
	div.addEventListener("dragover", function(event) { dragOver(event); });
	div.addEventListener("drop", function(event) { drop(event); });
	div.setAttribute("draggable", "true");
	root.insertBefore(div, last);
}


//================================================
// Context Menu
//================================================
var contextHeight = null;
function contextMenu(event) {
	event.preventDefault();
	event.stopPropagation();
	var myContextMenu = document.getElementById("myContextMenu");
	if (myContextMenu.style.display !== "none") { return false; }
	var contextLeft = event.clientX + document.body.scrollLeft - 3;
	var contextTop = event.clientY + document.body.scrollTop - 3;
	var mostBottomTop = window.innerHeight + document.body.scrollTop - contextHeight;
	if (contextTop > mostBottomTop) {contextTop = mostBottomTop;}
	myContextMenu.style.left = contextLeft.toString() + "px";
	myContextMenu.style.top = contextTop.toString() + "px";
	document.getElementById("changeFavicon").removeAttribute("data-clickable");
	document.getElementById("pinFavicon").removeAttribute("data-clickable");
	document.getElementById("resetFavicon").removeAttribute("data-clickable");
	document.getElementById("removeFavicon").removeAttribute("data-clickable");
	document.getElementById("exportFavicon").removeAttribute("data-clickable");
	document.getElementById("editTitle").removeAttribute("data-clickable");
	document.getElementById("deleteBookmark").removeAttribute("data-clickable");
	document.getElementById("undoDeleteBookmark").removeAttribute("data-clickable");
	if (event.target.id.indexOf("-") === -1) {
		if ((event.target.id !== "0") && (event.target.id !== "lastRow")) { return false; }
		clearAll();
	} else {
		var div = document.getElementById("div-" + event.target.id.split("-")[1]);
		if (!div.hasAttribute("data-selected")) {
			clearAll();
			div.setAttribute("data-selected", true);
			document.getElementById("checkBox-" + event.target.id.split("-")[1]).checked = true;
		}
		var usableCount = 0;
		var nonUsableCount = 0;
		var folderCount = 0;
		var divs = document.getElementsByTagName("div");
		for (var i=0; i < divs.length; i++) {
			if (divs[i].id.indexOf("-") !== -1) {
				if (divs[i].hasAttribute("data-selected")) {
					if (divs[i].hasAttribute("title")) {
						if (backgroundWin.isUsableURL(divs[i].getAttribute("title"))) {
							usableCount ++;
						} else {
							nonUsableCount ++;
						}
					} else {
						folderCount ++;
					}
				}
			}
		}
		if ((folderCount === 0) && (nonUsableCount === 0) && (usableCount == 1)) {
			document.getElementById("changeFavicon").setAttribute("data-clickable", true);
		}
		if ((folderCount === 0) && (nonUsableCount === 0) && (usableCount > 0)) {
			document.getElementById("pinFavicon").setAttribute("data-clickable", true);
			document.getElementById("resetFavicon").setAttribute("data-clickable", true);
			document.getElementById("removeFavicon").setAttribute("data-clickable", true);
		}
		if ((folderCount === 0) && ((nonUsableCount + usableCount) > 0)) {
			document.getElementById("exportFavicon").setAttribute("data-clickable", true);
		}
		if ((folderCount + usableCount + nonUsableCount) === 1) {
			document.getElementById("editTitle").setAttribute("data-clickable", true);
		}
		if ((folderCount + usableCount + nonUsableCount) > 0) {
			document.getElementById("deleteBookmark").setAttribute("data-clickable", true);
		}
	}
	if (window.top.undoDeleteHistory.length > 0) {
		document.getElementById("undoDeleteBookmark").setAttribute("data-clickable", true);
	}
	myContextMenu.style.display = "block";
	return false;
}
function mouseOutContext(event) {
	var myContextMenu = document.getElementById("myContextMenu");
	var contextLeft = Number(myContextMenu.style.left.substr(0, myContextMenu.style.left.length - 2));
	var contextTop = Number(myContextMenu.style.top.substr(0, myContextMenu.style.top.length - 2));
	var relativeX = event.clientX + document.body.scrollLeft - contextLeft;
	var relativeY = event.clientY + document.body.scrollTop - contextTop;
	if ((relativeX < 0) || (relativeX >= myContextMenu.offsetWidth) || (relativeY < 0) || (relativeY >= myContextMenu.offsetHeight)) {
		myContextMenu.style.display = "none";
	}
}


//================================================
// Favicon manipulate
//================================================
function changeFavicon(event) {
	var imageFile = event.target.files[0];
	var reader = new FileReader();
	reader.addEventListener("abort", function(event) {
		window.top.logWin.log("red", "Error - File reading abort.");
		document.getElementById("myContextMenu").style.display = "none";
	});
	reader.addEventListener("error", function(event) {
		window.top.logWin.log("red", "Error - File reading error.");
		document.getElementById("myContextMenu").style.display = "none";
	});
	reader.addEventListener("loadend", function(event) {
		var img = new Image();
		img.addEventListener("abort", function(event) {
			window.top.logWin.log("red", "Error - Image loading abort.");
			document.getElementById("myContextMenu").style.display = "none";
		});
		img.addEventListener("error", function(event) {
			window.top.logWin.log("red", "Error - Image error or not support.");
			document.getElementById("myContextMenu").style.display = "none";
		});
		img.addEventListener("load", function(event) {
			var pageCustomFavicon = backgroundWin.changeImageToDataURL(event.target);
			var targetURL = getSelectedURLs()[0];
			window.top.changeFavicon(targetURL, pageCustomFavicon, backgroundWin.nullPNG);
			clearAll();
			document.getElementById("myContextMenu").style.display = "none";
		});
		var imageDataURL = backgroundWin.ico16x16Resolution(event.target.result);
		img.src = imageDataURL;
	});
	reader.readAsDataURL(imageFile);
}
function pinFavicon() {
	var targetURLs = getSelectedURLs();
	for (var i=0; i < targetURLs.length; i++) {
		var targetURL = targetURLs[i];
		window.top.pinFavicon(targetURL);
	}
	clearAll();
	document.getElementById("myContextMenu").style.display = "none";
}
function resetFavicon() {
	var targetURLs = getSelectedURLs();
	if (targetURLs.length > 1) {
		if (!confirm("Are you sure to reset multiple favicons?")) {
			document.getElementById("myContextMenu").style.display = "none";
			return;
		}
	}
	for (var i=0; i < targetURLs.length; i++) {
		var targetURL = targetURLs[i];
		window.top.resetFavicon(targetURL);
	}
	clearAll();
	document.getElementById("myContextMenu").style.display = "none";
}
function removeFavicon() {
	var targetURLs = getSelectedURLs();
	if (targetURLs.length > 1) {
		if (!confirm("Are you sure to remove multiple favicons?")) {
			document.getElementById("myContextMenu").style.display = "none";
			return;
		}
	}
	for (var i=0; i < targetURLs.length; i++) {
		var targetURL = targetURLs[i];
		window.top.removeFavicon(targetURL);
	}
	clearAll();
	document.getElementById("myContextMenu").style.display = "none";
}
function exportFavicon() {
	if (!window.top.exportActive) {
		var targetURLs = getSelectedURLs();
		if (targetURLs.length === 1) {
			var exportFileName = document.getElementById("fontEdit-" + getSelectedRowIds()[0]).getAttribute("data-bookmarkTitle").replace(/^\s+|\s+$/g, "") + ".png";
			if (exportFileName === ".png") {
				exportFileName = "favicon.png";
			}
			var pageURL = targetURLs[0];
			window.top.exportSingleFavicon(pageURL, exportFileName);
		} else {
			var pageURLs = targetURLs;
			window.top.exportMultipleFavicon(pageURLs, []);
		}
	}
	clearAll();
	document.getElementById("myContextMenu").style.display = "none";
}


//================================================
// Button
//================================================
function selectAll() {
	var allRowIds = getAllRowIds();
	for (var i=0; i < allRowIds.length; i++) {
		document.getElementById("div-" + allRowIds[i]).setAttribute("data-selected", true);
		document.getElementById("checkBox-" + allRowIds[i]).checked = true;
	}
}
function selectNonFolder() {
	var divs = document.getElementsByTagName("div")
	for (var i=0; i < divs.length; i++) {
		if (divs[i].id.indexOf("-") !== -1) {
			if (divs[i].hasAttribute("title")) {
				divs[i].setAttribute("data-selected", true);
				document.getElementById("checkBox-" + divs[i].id.split("-")[1]).checked = true;
			} else {
				divs[i].removeAttribute("data-selected");
				document.getElementById("checkBox-" + divs[i].id.split("-")[1]).checked = false;
			}
		}
	}
}
function selectResetable() {
	var divs = document.getElementsByTagName("div")
	for (var i=0; i < divs.length; i++) {
		if (divs[i].id.indexOf("-") !== -1) {
			if (divs[i].hasAttribute("title")) {
				var pageURL = divs[i].getAttribute("title");
				if (backgroundWin.isUsableURL(pageURL)) {
					divs[i].setAttribute("data-selected", true);
					document.getElementById("checkBox-" + divs[i].id.split("-")[1]).checked = true;
				} else {
					divs[i].removeAttribute("data-selected");
					document.getElementById("checkBox-" + divs[i].id.split("-")[1]).checked = false;
				}
			} else {
				divs[i].removeAttribute("data-selected");
				document.getElementById("checkBox-" + divs[i].id.split("-")[1]).checked = false;
			}
		}
	}
}
function clearAll() {
	var allRowIds = getAllRowIds();
	for (var i=0; i < allRowIds.length; i++) {
		document.getElementById("div-" + allRowIds[i]).removeAttribute("data-selected");
		document.getElementById("checkBox-" + allRowIds[i]).checked = false;
	}
}


//================================================
// Node click
//================================================
function nodeClick(event) {
	event.stopPropagation();
	if ((event.target.id === "0") || (event.target.id === "lastRow")) {
		clearAll();
	} else {
		var rowId = event.target.id.split("-")[1];
		if (document.getElementById("div-" + rowId).hasAttribute("data-selected")) {
			document.getElementById("div-" + rowId).removeAttribute("data-selected");
			document.getElementById("checkBox-" + rowId).checked = false;
		} else {
			document.getElementById("div-" + rowId).setAttribute("data-selected", true);
			document.getElementById("checkBox-" + rowId).checked = true;
		}
	}
}
function nodeDblClick(event) {
	var rowId = event.target.id.split("-")[1];
	window.top.targetFolder = rowId;
	window.top.targetBookmark = "0";
	currentFolderId = 0;
	window.top.folderWin.location.reload(true);
}


//================================================
// Edit Box
//================================================
function editTitleClick() {
	var selectedRowIds = getSelectedRowIds();
	openEditBox(selectedRowIds[0]);
	clearAll();
	document.getElementById("myContextMenu").style.display = "none";
}
function openEditBox(rowId) {
	var div = document.getElementById("div-" + rowId);
	div.removeAttribute("data-selected");
	document.getElementById("checkBox-" + rowId).checked = false;
	var fontEdit = document.getElementById("fontEdit-" + rowId);
	var rect = fontEdit.getBoundingClientRect();
	var calculatedWidth = rect.width;
	if (calculatedWidth < 200) {calculatedWidth = 200;}
	var myEditBox = document.getElementById("myEditBox");
	var myEditBoxDiv = document.getElementById("myEditBoxDiv");
	myEditBoxDiv.style.left = (rect.left + 4).toString() + "px";
	myEditBoxDiv.style.top = (rect.top - 1).toString() + "px";
	myEditBoxDiv.style.width = calculatedWidth.toString() + "px";
	myEditBox.style.width = calculatedWidth.toString() + "px";
	myEditBox.setAttribute("data-rowId", rowId);
	document.getElementById("transparentGlass").style.display = "block";
	myEditBox.value = fontEdit.getAttribute("data-bookmarkTitle");
	myEditBoxDiv.style.display = "block";
	myEditBox.focus();
}
function closeEditBox() {
	if (document.getElementById("myEditBoxDiv").style.display === "block") {
		document.getElementById("myEditBoxDiv").style.display = "none";
		document.getElementById("transparentGlass").style.display = "none";
		var myEditBox = document.getElementById("myEditBox");
		var newTitle = myEditBox.value.replace(/^\s+|\s+$/g, "");
		var rowId = myEditBox.getAttribute("data-rowId");
		var fontEdit = document.getElementById("fontEdit-" + rowId);
		if (newTitle !== fontEdit.getAttribute("data-bookmarkTitle")) {
			var bookmarkId = rowId.toString();
			(function(bookmarkId, fontEdit, newTitle) {
				chrome.bookmarks.update(bookmarkId, {title:newTitle}, function(result) {
					if (!result) {
						backgroundWin.bannedWatch();
						window.top.logWin.log("red", "Error update bookmark");
					} else {
						fontEdit.removeChild(fontEdit.childNodes[0]);
						fontEdit.appendChild(document.createTextNode(" " + newTitle));
						fontEdit.setAttribute("data-bookmarkTitle", newTitle);
						if (!result.url) {
							window.top.folderWin.location.reload(true);
						}
					}
				});
			})(bookmarkId, fontEdit, newTitle);
		}
	}
}


//================================================
// Drag Drop
//================================================
var moveRowIds = null;
var moveFolderToOtherFolder = null;
function dragStart(event) {
	var rowId = event.target.id.split("-")[1];
	if (getSelectedRowIds().length === 0) {
		document.getElementById("div-" + rowId).setAttribute("data-selected");
		document.getElementById("checkBox-" + rowId).checked = true;
	}
}
function cleanDropMarker() {
	var allRowIds = getAllRowIds();
	for (var i=0; i < allRowIds.length; i++) {
		document.getElementById("div-" + allRowIds[i]).removeAttribute("data-insert");
	}
	document.getElementById("firstRow").removeAttribute("data-insert");
	document.getElementById("lastRow").removeAttribute("data-insert");
}
function reWriteBeforeAfter() {
	var prior = "firstRow";
	var priorDiv = document.getElementById("firstRow");
	var divs = document.getElementsByTagName("div");
	for (var i=0; i < divs.length; i++) {
		if (divs[i].id.indexOf("-") !== -1) {
			var rowId = divs[i].id.split("-")[1];
			divs[i].setAttribute("data-rowBeforeId", prior);
			priorDiv.setAttribute("data-rowAfterId", rowId);
			prior = rowId;
			priorDiv = divs[i];
		}
	}
	document.getElementById("lastRow").setAttribute("data-rowBeforeId", prior);
	priorDiv.setAttribute("data-rowAfterId", "lastRow");
}
function canDrop(rowId) {
	if (rowId === "0") { return false; }
	try {
		return (!document.getElementById("div-" + rowId).hasAttribute("data-selected"));
	} catch(e) {
		return true;
	}
}
function dragOver(event) {
	event.stopPropagation();
	cleanDropMarker();
	var mouseLeft = event.clientX + document.body.scrollLeft;
	var mouseTop = event.clientY + document.body.scrollTop;
	if ((event.target.id === "0") || (event.target.id === "lastRow")) {
		var rowId = document.getElementById("lastRow").getAttribute("data-rowBeforeId");
		if (rowId === "firstRow") { return; }
		var div = document.getElementById("div-" + rowId);
		var dropAt = "after";
	} else {
		var rowId = event.target.id.split("-")[1];
		var div = document.getElementById("div-" + rowId);
		var rect = div.getBoundingClientRect();
		var fromTop = (mouseTop - rect.top);
		var dropAt = "exactly";
		if (div.hasAttribute("title")) {
			if ((fromTop * 2) < rect.height) {
				dropAt = "before";
			} else {
				dropAt = "after";
			}
		} else {
			if ((fromTop * 4) < rect.height) {
				dropAt = "before";
			} else if ((fromTop * 4) > (rect.height * 3)) {
				dropAt = "after";
			} else {
				if (!canDrop(rowId)) { return; }
			}
		}
	}
	event.preventDefault();
	if (dropAt === "before") {
		div.setAttribute("data-insert", "before");
		var rowBeforeId = div.getAttribute("data-rowBeforeId");
		if (rowBeforeId === "firstRow") {
			document.getElementById("firstRow").setAttribute("data-insert", "after");
		} else {
			document.getElementById("div-" + rowBeforeId).setAttribute("data-insert", "after");
		}
	} else if (dropAt === "after") {
		div.setAttribute("data-insert", "after");
		var rowAfterId = div.getAttribute("data-rowAfterId");
		if (rowAfterId === "lastRow") {
			document.getElementById("lastRow").setAttribute("data-insert", "before");
		} else {
			document.getElementById("div-" + rowAfterId).setAttribute("data-insert", "before");
		}
	}
}
function dragEnd() {
	event.stopPropagation();
	event.preventDefault();
	cleanDropMarker();
}
function drop(event) {
	event.stopPropagation();
	event.preventDefault();
	if ((event.target.id === "0") || (event.target.id === "lastRow")) {
		var moveTo = getAllRowIds().length;
	} else {
		var rowId = event.target.id.split("-")[1];
		var div = document.getElementById("div-" + rowId);
		if (div.hasAttribute("data-insert")) {
			var allRowIds = getAllRowIds();
			var moveTo = allRowIds.indexOf(rowId);
			if (div.getAttribute("data-insert") === "after") {
				moveTo ++;
			}
		} else {
			if (canDrop(rowId)) {
				dropInFolder(rowId);
			}
			return;
		}
	}
	moveRowIds = getSelectedRowIds();
	moveRows(moveTo);
}
function moveRows(moveTo) {
	if (moveRowIds.length > 0) {
		(function(moveTo) {
			chrome.bookmarks.move(moveRowIds[0], {index:moveTo}, function(result) {
				moveRowIds.shift();
				if (!result) {
					backgroundWin.bannedWatch();
					window.top.logWin.log("red", "Error move bookmark");
					moveRows(moveTo);
				} else {
					moveRows(result.index + 1);
				}
			});
		})(moveTo);
	} else {
		window.top.bookmarkWinScrollTop = document.getElementById("0").scrollTop;
		window.location.reload(true);
	}
}
function dropInFolder(folderId) {
	moveRowIds = getSelectedRowIds();
	moveFolderToOtherFolder = false;
	moveRowsToFolder(folderId);
}
function moveRowsToFolder(folderId) {
	if (moveRowIds.length > 0) {
		(function(folderId) {
			chrome.bookmarks.move(moveRowIds[0], {parentId:folderId}, function(result) {
				moveRowIds.shift();
				if (!result) {
					backgroundWin.bannedWatch();
					window.top.logWin.log("red", "Error move bookmark");
				} else {
					if (!result.url) {
						moveFolderToOtherFolder = true;
					}
				}
				moveRowsToFolder(folderId);
			});
		})(folderId);
	} else {
		if (moveFolderToOtherFolder) {
			currentFolderId = 0;
			window.top.folderWin.location.reload(true);
		} else {
			window.top.bookmarkWinScrollTop = document.getElementById("0").scrollTop;
			window.location.reload(true);
		}
	}
}


//================================================
// Delete UndoDelete
//================================================
var nodesToDelete = null;
var undoDeleteData = null;
var folderHadDeleted = null;
var restoreData = null;
var restoreParentId = null;
function deleteBookmark() {
	nodesToDelete = getSelectedRowIds();
	if (nodesToDelete.length === 0) {
		return;
	}
	var divs = document.getElementsByTagName("div");
	for (var i=0; i < divs.length; i++) {
		if (divs[i].id.indexOf("-") !== -1) {
			if (divs[i].hasAttribute("data-selected")) {
				if (!divs[i].hasAttribute("title")) {
					if (!confirm("Warning! Are you sure to delete folder(s)? This cannot be undone.")) {
						return;
					}
					break;
				}
			}
		}
	}
	undoDeleteData = [];
	folderHadDeleted = false;
	recursiveDelete();
}
function recursiveDelete() {
	if (nodesToDelete.length !== 0) {
		var rowId = nodesToDelete[0];
		nodesToDelete.shift();
		if (document.getElementById("div-" + rowId).hasAttribute("title")) {
			var pageTitle = document.getElementById("fontEdit-" + rowId).getAttribute("data-bookmarkTitle");
			var pageURL = document.getElementById("div-" + rowId).getAttribute("title")
			if (currentFolderId === backgroundWin.bookmarkBarId) {
				if (backgroundWin.autoHideBookmarkBarName) {
					var i = backgroundWin.bookmarkBarName.id.indexOf(rowId);
					if (i !== -1) {
						pageTitle = decodeURIComponent(escape(window.atob(bookmarkBarName.title[i])));
					}
				}
			}
			(function(rowId, currentFolderId, pageTitle, pageURL) {
				chrome.bookmarks.remove(rowId, function() {
					backgroundWin.bannedWatch();
					if (backgroundWin.banned) {
						window.top.logWin.log("red", "Error delete bookmark");
					} else {
						undoDeleteData.push({parentId:currentFolderId, title:pageTitle, url:pageURL});
					}
					recursiveDelete();
				});
			})(rowId, currentFolderId, pageTitle, pageURL);
		} else {
			chrome.bookmarks.removeTree(rowId, function() {
				backgroundWin.bannedWatch();
				if (backgroundWin.banned) {
					window.top.logWin.log("red", "Error delete bookmark folder");
				} else {
					folderHadDeleted = true;
				}
				recursiveDelete();
			});
		}
		document.getElementById("0").removeChild(document.getElementById("div-" + rowId));
	} else {
		reWriteBeforeAfter();
		if (undoDeleteData.length !== 0) {
			window.top.undoDeleteHistory.push(undoDeleteData);
		}
		clearAll();
		document.getElementById("myContextMenu").style.display = "none";
		if (folderHadDeleted) {
			window.top.folderWin.location.reload(true);
		}
	}
}
function undoDeleteBookmark() {
	restoreData = window.top.undoDeleteHistory.pop();
	restoreParentId = restoreData[0].parentId;
	chrome.bookmarks.get(restoreParentId, function(results) {
		if (!results) {
			restoreParentId = backgroundWin.bookmarkOtherId;
		}
		recursiveUndoDelete();
	});
}
function recursiveUndoDelete() {
	if (restoreData.length !== 0) {
		chrome.bookmarks.create({parentId:restoreParentId, title:restoreData[0].title, url:restoreData[0].url}, function(result) {
			if (!result) {
				backgroundWin.bannedWatch();
				window.top.logWin.log("red", "Error undo bookmark delete.");
				window.top.undoDeleteHistory.push(restoreData);
				restoreData = [];
			} else {
				if (restoreParentId === currentFolderId) {
					addRow(result);
				}
				restoreData.shift();
			}
			recursiveUndoDelete();
		});
	} else {
		if (restoreParentId === currentFolderId) {
			reWriteBeforeAfter();
			clearAll();
			document.getElementById("myContextMenu").style.display = "none";
		} else {
			window.top.targetFolder = restoreParentId;
			window.top.targetBookmark = "0";
			currentFolderId = 0;
			window.top.folderWin.location.reload(true);
		}
	}
}


//================================================
// Add Folder
//================================================
function addFolderClick() {
	clearAll();
	document.getElementById("myContextMenu").style.display = "none";
	chrome.bookmarks.create({parentId:currentFolderId}, function(result) {
		if (!result) {
			backgroundWin.bannedWatch();
			window.top.logWin.log("red", "Error create bookmark folder");
		} else {
			addRow(result);
			reWriteBeforeAfter();
			var lastRow = document.getElementById("lastRow");
			lastRow.parentNode.scrollTop = lastRow.offsetTop - lastRow.parentNode.offsetTop;
			openEditBox(result.id);
		}
	});
}


//================================================
// Bookmark Change Capture
//================================================
var currentTabId = null;
var refresh = function() {
	currentFolderId = 0;
	window.top.folderWin.location.reload(true);
}
chrome.tabs.getCurrent(function(tab) {
	currentTabId = tab.id;
	chrome.tabs.onActivated.addListener(function(activeInfo) {
		if (activeInfo.tabId === currentTabId) {
			chrome.bookmarks.onCreated.removeListener(refresh);
			chrome.bookmarks.onRemoved.removeListener(refresh);
			chrome.bookmarks.onChanged.removeListener(refresh);
			chrome.bookmarks.onMoved.removeListener(refresh);
			chrome.bookmarks.onChildrenReordered.removeListener(refresh);
			chrome.bookmarks.onImportEnded.removeListener(refresh);
		} else {
			chrome.bookmarks.onCreated.addListener(refresh);
			chrome.bookmarks.onRemoved.addListener(refresh);
			chrome.bookmarks.onChanged.addListener(refresh);
			chrome.bookmarks.onMoved.addListener(refresh);
			chrome.bookmarks.onChildrenReordered.addListener(refresh);
			chrome.bookmarks.onImportEnded.addListener(refresh);
		}
	});
});


//================================================
// Begin here
//================================================
document.addEventListener("DOMContentLoaded", function() {
	window.top.bookmarkWin = window;
	backgroundWin = window.top.backgroundWin;
	var myContextMenu = document.getElementById("myContextMenu");
	contextHeight = myContextMenu.offsetHeight;
	myContextMenu.style.display = "none";
	myContextMenu.style.opacity = 1;
	currentFolderId = window.top.targetFolder;
	chrome.bookmarks.getChildren(currentFolderId, function(results) {
		for (var i=0; i < results.length; i++) {
			addRow(results[i]);
		}
		reWriteBeforeAfter();
		resizeContent();
		var targetBookmark = window.top.targetBookmark;
		window.top.targetBookmark = "0";
		if (targetBookmark !== "0") {
			var allRowIds = getAllRowIds();
			var i = allRowIds.indexOf(targetBookmark);
			if (i !== -1) {
				var targetDiv = document.getElementById("div-" + allRowIds[i]);
				targetDiv.parentNode.scrollTop = targetDiv.offsetTop - targetDiv.parentNode.offsetTop;
				targetDiv.setAttribute("data-selected", true);
				document.getElementById("checkBox-" + allRowIds[i]).checked = true;
			}
		} else {
			document.getElementById("0").scrollTop = window.top.bookmarkWinScrollTop;
		}
		window.top.bookmarkWinScrollTop = 0;
		chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
			if (request.command === "updateList") {
				var pageURL = request.pageURL;
				var pageCustomFavicon = request.pageCustomFavicon;
				var divs = document.getElementsByTagName("div");
				for (var i=0; i < divs.length; i++) {
					if (divs[i].id.indexOf("-") !== -1) {
						if (pageURL === divs[i].getAttribute("title")) {
							document.getElementById("img-" + divs[i].id.split("-")[1]).src = pageCustomFavicon;
						}
					}
				}
			}
		});
		window.addEventListener("resize", function() {
			resizeContent();
		});
		document.getElementById("selectAll").addEventListener("click", function(event) {
			selectAll();
		});
		document.getElementById("selectNonFolder").addEventListener("click", function(event) {
			selectNonFolder();
		});
		document.getElementById("selectResetable").addEventListener("click", function(event) {
			selectResetable();
		});
		document.getElementById("selectNone").addEventListener("click", function(event) {
			clearAll();
		});
		document.getElementById("refresh").addEventListener("click", refresh);
		document.getElementById("help").addEventListener("click", function(event) {
			chrome.windows.create({url:"help.xhtml", width:750, height:520, focused:true, incognito:false, type:"popup"});
		});
		document.getElementById("firstRow").addEventListener("click", function(event) {
			event.stopPropagation();
		});
		document.getElementById("firstRow").addEventListener("dragover", function(event) {
			event.stopPropagation();
		});
		document.getElementById("firstRow").addEventListener("drop", function(event) {
			event.stopPropagation();
		});
		document.getElementById("lastRow").addEventListener("click", function(event) {
			nodeClick(event);
		});
		document.getElementById("lastRow").addEventListener("dragover", function(event) {
			dragOver(event);
		});
		document.getElementById("lastRow").addEventListener("drop", function(event) {
			drop(event);
		});
		document.getElementById("0").addEventListener("click", function(event) {
			nodeClick(event);
		});
		document.getElementById("0").addEventListener("dragover", function(event) {
			dragOver(event);
		});
		document.getElementById("0").addEventListener("drop", function(event) {
			drop(event);
		});
		document.getElementById("0").addEventListener("dragend", function(event) {
			dragEnd(event);
		});
		document.getElementById("myContextMenu").addEventListener("mouseout", function(event) {
			mouseOutContext(event);
		});
		window.addEventListener("contextmenu", function(event) {
			return contextMenu(event);
		});
		document.getElementById("changeFavicon").addEventListener("click", function(event) {
			if (document.getElementById("changeFavicon").hasAttribute("data-clickable")) {
				document.getElementById("changeFaviconInput").value = "";
				document.getElementById("changeFaviconInput").click();
			}
		});
		document.getElementById("changeFaviconInput").addEventListener("change", function(event) {
			changeFavicon(event);
		});
		document.getElementById("pinFavicon").addEventListener("click", function(event) {
			if (document.getElementById("pinFavicon").hasAttribute("data-clickable")) {
				pinFavicon();
			}
		});
		document.getElementById("resetFavicon").addEventListener("click", function(event) {
			if (document.getElementById("resetFavicon").hasAttribute("data-clickable")) {
				resetFavicon();
			}
		});
		document.getElementById("removeFavicon").addEventListener("click", function(event) {
			if (document.getElementById("removeFavicon").hasAttribute("data-clickable")) {
				removeFavicon();
			}
		});
		document.getElementById("exportFavicon").addEventListener("click", function(event) {
			if (document.getElementById("exportFavicon").hasAttribute("data-clickable")) {
				exportFavicon();
			}
		});
		document.getElementById("editTitle").addEventListener("click", function(event) {
			if (document.getElementById("editTitle").hasAttribute("data-clickable")) {
				editTitleClick();
			}
		});
		document.getElementById("myEditBox").addEventListener("keyup", function(event) {
			event.stopPropagation();
			if (event.keyCode === 13) {
				document.getElementById("myEditBox").blur();
			}
		});
		document.getElementById("myEditBox").addEventListener("blur", function(event) {
			closeEditBox();
		});
		document.getElementById("deleteBookmark").addEventListener("click", function(event) {
			if (document.getElementById("deleteBookmark").hasAttribute("data-clickable")) {
				deleteBookmark();
			}
		});
		document.getElementById("undoDeleteBookmark").addEventListener("click", function(event) {
			if (document.getElementById("undoDeleteBookmark").hasAttribute("data-clickable")) {
				undoDeleteBookmark();
			}
		});
		window.addEventListener("keyup", function(event) {
			if (event.keyCode === 46) {
				deleteBookmark();
			}
		});
		document.getElementById("addFolder").addEventListener("click", function(event) {
			addFolderClick();
		});
	});
});
