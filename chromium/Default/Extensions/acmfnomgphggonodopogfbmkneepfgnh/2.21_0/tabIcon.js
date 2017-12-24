//================================================================
// Bookmark Favicon Changer by Sonthakit Leelahanon.
// Copyright 2014 Sonthakit Leelahanon. All rights reserved.
//================================================================
"use strict";


var backgroundWin = null;
var nextRowId = 1;
var rowIdTable = [];


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
function addRow(faviconURL, URLRule, URLRegExp) {
	var root = document.getElementById("0");
	var div = document.createElement("div");
	var rowId = nextRowId.toString();
	nextRowId ++;
	div.id = "div-" + rowId;
	div.setAttribute("class", "divRow");
	var img = document.createElement("img");
	img.id = "img-" + rowId;
	img.setAttribute("class", "favicon");
	img.style.paddingRight = "6px";
	img.src = faviconURL;
	img.addEventListener("click", function(event) { imgClick(event); });
	var fontEdit = document.createElement("font");
	fontEdit.id = "fontEdit-" + rowId;
	fontEdit.setAttribute("class", "fontEdit");
	fontEdit.setAttribute("data-URLRule", URLRule);
	fontEdit.setAttribute("data-URLRegExp", URLRegExp);
	fontEdit.appendChild(document.createTextNode(URLRule));
	var divEdit = document.createElement("div");
	divEdit.id = "divEdit-" + rowId;
	divEdit.setAttribute("class", "divEdit");
	divEdit.addEventListener("click", function(event) { urlRuleClick(event); });
	var imgEdit = document.createElement("img");
	imgEdit.id = "imgEdit-" + rowId;
	imgEdit.setAttribute("class", "favicon");
	imgEdit.src = "edit.png";
	imgEdit.addEventListener("click", function(event) { urlRuleClick(event); });
	var imgDelete = document.createElement("img");
	imgDelete.id = "imgDelete-" + rowId;
	imgDelete.setAttribute("class", "favicon");
	imgDelete.src = "delete.png";
	imgDelete.addEventListener("click", function(event) { deleteClick(event); });
	var imgExport = document.createElement("img");
	imgExport.id = "imgExport-" + rowId;
	imgExport.setAttribute("class", "favicon");
	imgExport.src = "export.png";
	imgExport.addEventListener("click", function(event) { exportClick(event); });
	div.appendChild(img);
	divEdit.appendChild(fontEdit);
	div.appendChild(divEdit);
	div.appendChild(imgEdit);
	div.appendChild(imgDelete);
	div.appendChild(imgExport);
	div.addEventListener("dragstart", function(event) { dragStart(event); });
	div.setAttribute("draggable", "true");
	root.appendChild(div);
	rowIdTable.push(rowId);
	return rowId;
}


//================================================
// Drag Drop
//================================================
var floatDiv = null;
var floatPosition = null;
var floatStartTop = null;
var dragStartTop = null;
function dragStart(event) {
	var rowId = event.target.id.split("-")[1];
	floatPosition = rowIdTable.indexOf(rowId);
	floatDiv = event.target;
	dragStartTop = event.clientY + document.body.scrollTop;
	var rect = floatDiv.getBoundingClientRect();
	var root = document.getElementById("0");
	var blankDiv = document.createElement("div");
	blankDiv.id = "blank";
	blankDiv.setAttribute("class", "divRow");
	blankDiv.style.border = "1px solid #CFECEC";
	blankDiv.style.backgroundColor = "#CFECEC";
	root.insertBefore(blankDiv, floatDiv);
	floatDiv.style.zIndex = "10";
	floatDiv.style.position = "absolute";
	floatDiv.style.left = (rect.left + 0).toString() + "px";
	floatStartTop = (rect.top + 0);
	floatDiv.style.top = floatStartTop.toString() + "px";
}
function dragOver(event) {
	event.stopPropagation();
	var mouseTop = event.clientY + document.body.scrollTop;
	var relativeMove = mouseTop - dragStartTop;
	floatDiv.style.top = (floatStartTop + relativeMove).toString() + "px";
	var root = document.getElementById("0");
	var rect = root.getBoundingClientRect();
	var relativeRoot = mouseTop - rect.top;
	if (relativeRoot >= 0) {
		var blankDiv = document.getElementById("blank");
		var blankRect = blankDiv.getBoundingClientRect();
		var relativePosition = Math.floor(relativeRoot / blankRect.height);
		root.removeChild(blankDiv);
		if (relativePosition >= (rowIdTable.length-1)) {
			root.appendChild(blankDiv);
		} else if (relativePosition < floatPosition) {
			var div = document.getElementById("div-" + rowIdTable[relativePosition]);
			root.insertBefore(blankDiv, div);
		} else {
			var div = document.getElementById("div-" + rowIdTable[relativePosition + 1]);
			root.insertBefore(blankDiv, div);
		}
		event.preventDefault();
	}
}
function drop(event) {
	event.stopPropagation();
	var mouseTop = event.clientY + document.body.scrollTop;
	var root = document.getElementById("0");
	var rect = root.getBoundingClientRect();
	var blankDiv = document.getElementById("blank");
	var blankRect = blankDiv.getBoundingClientRect();
	root.removeChild(blankDiv);
	floatDiv.style.removeProperty("zIndex");
	floatDiv.style.removeProperty("position");
	floatDiv.style.removeProperty("left");
	floatDiv.style.removeProperty("top");
	var floatDivRowId = floatDiv.id.split("-")[1];
	var relativeRoot = mouseTop - rect.top;
	if (relativeRoot >= 0) {
		var relativePosition = Math.floor(relativeRoot / blankRect.height);
		if (relativePosition >= (rowIdTable.length-1)) {
			root.removeChild(floatDiv);
			root.appendChild(floatDiv);
			rowIdTable.splice(floatPosition, 1);
			rowIdTable.push(floatDivRowId);
			var removeRules = backgroundWin.tabIconRule.splice(floatPosition, 1);
			backgroundWin.tabIconRule.push(removeRules[0]);
		} else {
			if (relativePosition < floatPosition) {
				var div = document.getElementById("div-" + rowIdTable[relativePosition]);
			} else {
				var div = document.getElementById("div-" + rowIdTable[relativePosition + 1]);
			}
			root.removeChild(floatDiv);
			root.insertBefore(floatDiv, div);
			rowIdTable.splice(floatPosition, 1);
			rowIdTable.splice(relativePosition, 0, floatDivRowId);
			var removeRules = backgroundWin.tabIconRule.splice(floatPosition, 1);
			backgroundWin.tabIconRule.splice(relativePosition, 0, removeRules[0]);
		}
		backgroundWin.saveTabIconRule();
		backgroundWin.sendAllContentScriptProperFavicon();
		event.preventDefault();
	}
	floatDiv = null;
}
function dragEnd() {
	event.stopPropagation();
	event.preventDefault();
	if (floatDiv !== null) {
		var root = document.getElementById("0");
		var blankDiv = document.getElementById("blank");
		root.removeChild(blankDiv);
		floatDiv.style.removeProperty("zIndex");
		floatDiv.style.removeProperty("position");
		floatDiv.style.removeProperty("left");
		floatDiv.style.removeProperty("top");
	}
}


//================================================
// Add New Rule
//================================================
function addNewRule() {
	var root = document.getElementById("0");
	var exampleRule = "http*://www.example.com/*";
	var exampleRegExp = backgroundWin.ruleToRegExp(exampleRule);
	var rowId = addRow(backgroundWin.pageDefaultFavicon, exampleRule, exampleRegExp);
	var newDiv = document.getElementById("div-" + rowId);
	backgroundWin.tabIconRule.push({tabIconURL:backgroundWin.pageDefaultFavicon, URLRule:exampleRule, URLRegExp:exampleRegExp});
	backgroundWin.saveTabIconRule();
	backgroundWin.sendAllContentScriptProperFavicon();
	root.scrollTop = newDiv.offsetTop - root.offsetTop;
	openEditBox(newDiv.id.split("-")[1]);
}


//================================================
// Edit rule
//================================================
function urlRuleClick(event) {
	if (event.target.id.indexOf("-") !== -1) {
		openEditBox(event.target.id.split("-")[1]);
	}
}
function openEditBox(rowId) {
	var fontEdit = document.getElementById("fontEdit-" + rowId);
	var rect = document.getElementById("div-" + rowId).getBoundingClientRect();
	var myEditBox = document.getElementById("myEditBox");
	var myEditBoxDiv = document.getElementById("myEditBoxDiv");
	myEditBoxDiv.style.left = (rect.left + 26).toString() + "px";
	myEditBoxDiv.style.top = (rect.top + 2).toString() + "px";
	myEditBox.setAttribute("data-rowId", rowId);
	document.getElementById("transparentGlass").style.display = "block";
	myEditBox.value = fontEdit.getAttribute("data-URLRule");
	myEditBoxDiv.style.display = "block";
	myEditBox.focus();
}
function closeEditBox() {
	if (document.getElementById("myEditBoxDiv").style.display === "block") {
		document.getElementById("myEditBoxDiv").style.display = "none";
		document.getElementById("transparentGlass").style.display = "none";
		var myEditBox = document.getElementById("myEditBox");
		var newURLRule = myEditBox.value.replace(/^\s+|\s+$/g, "");
		var newURLRegExp = backgroundWin.ruleToRegExp(newURLRule);
		var rowId = myEditBox.getAttribute("data-rowId");
		var fontEdit = document.getElementById("fontEdit-" + rowId);
		var oldURLRule = fontEdit.getAttribute("data-URLRule");
		var oldURLRegExp = fontEdit.getAttribute("data-URLRegExp");
		if ((newURLRule !== oldURLRule) || (newURLRegExp !== oldURLRegExp)) {
			fontEdit.removeChild(fontEdit.childNodes[0]);
			fontEdit.appendChild(document.createTextNode(newURLRule));
			fontEdit.setAttribute("data-URLRule", newURLRule);
			fontEdit.setAttribute("data-URLRegExp", newURLRegExp);
			var tabIconURL = document.getElementById("img-" + rowId).src;
			var position = rowIdTable.indexOf(rowId);
			backgroundWin.tabIconRule[position] = {tabIconURL:tabIconURL, URLRule:newURLRule, URLRegExp:newURLRegExp};
			backgroundWin.saveTabIconRule();
			backgroundWin.sendAllContentScriptProperFavicon();
		}
	}
}
function imgClick(event) {
	if (event.target.id.indexOf("-") !== -1) {
		var rowId = event.target.id.split("-")[1];
		var input = document.getElementById("openFile");
		input.setAttribute("data-rowId", rowId);
		input.value = "";
		input.click();
	}
}
function changeRuleFavicon(event) {
	var imageFile = event.target.files[0];
	var reader = new FileReader();
	reader.addEventListener("abort", function(event) {
		window.top.logWin.log("red", "Error - File reading abort.");
	});
	reader.addEventListener("error", function(event) {
		window.top.logWin.log("red", "Error - File reading error.");
	});
	reader.addEventListener("loadend", function(event) {
		var img = new Image();
		img.addEventListener("abort", function(event) {
			window.top.logWin.log("red", "Error - Image loading abort.");
		});
		img.addEventListener("error", function(event) {
			window.top.logWin.log("red", "Error - Image error or not support.");
		});
		img.addEventListener("load", function(event) {
			var tabIconURL = backgroundWin.changeImageToDataURL(event.target);
			var input = document.getElementById("openFile");
			var rowId = input.getAttribute("data-rowId");
			document.getElementById("img-" + rowId).src = tabIconURL;
			var position = rowIdTable.indexOf(rowId);
			backgroundWin.tabIconRule[position].tabIconURL = tabIconURL;
			backgroundWin.saveTabIconRule();
			backgroundWin.sendAllContentScriptProperFavicon();
		});
		var imageDataURL = backgroundWin.ico16x16Resolution(event.target.result);
		img.src = imageDataURL;
	});
	reader.readAsDataURL(imageFile);
}


//================================================
// Delete Undo-delete Rule
//================================================
function deleteClick(event) {
	if (event.target.id.indexOf("-") !== -1) {
		var rowId = event.target.id.split("-")[1];
		var position = rowIdTable.indexOf(rowId);
		var div = document.getElementById("div-" + rowId);
		var root = document.getElementById("0");
		var rule = backgroundWin.tabIconRule[position];
		root.removeChild(div);
		rowIdTable.splice(position, 1);
		backgroundWin.tabIconRule.splice(position, 1);
		backgroundWin.saveTabIconRule();
		backgroundWin.sendAllContentScriptProperFavicon();
		window.top.undoTabIconRule.push(rule);
		document.getElementById("undoDelete").removeAttribute("disabled");
	}
}
function undoDelete() {
	var rule = window.top.undoTabIconRule.pop();
	if (window.top.undoTabIconRule.length === 0) {
		document.getElementById("undoDelete").setAttribute("disabled", "disabled");
	}
	var root = document.getElementById("0");
	var rowId = addRow(rule.tabIconURL, rule.URLRule, rule.URLRegExp);
	var newDiv = document.getElementById("div-" + rowId);
	backgroundWin.tabIconRule.push({tabIconURL:rule.tabIconURL, URLRule:rule.URLRule, URLRegExp:rule.RegExp});
	backgroundWin.saveTabIconRule();
	backgroundWin.sendAllContentScriptProperFavicon();
	root.scrollTop = newDiv.offsetTop - root.offsetTop;
}


//================================================
// Export Tab icon
//================================================
function exportClick(event) {
	if (event.target.id.indexOf("-") !== -1) {
		var rowId = event.target.id.split("-")[1];
		var tabIcon = document.getElementById("img-" + rowId).src;
		window.top.exportSingleIcon(tabIcon);
	}
}


//================================================
// Blink Row
//================================================
var blinkRowId = 0;
var blinkCount = 6;
function blinkRow() {
	try {
		if ((blinkCount % 2) === 0) {
			document.getElementById("div-"+blinkRowId.toString()).style.backgroundColor = "red";
		} else {
			document.getElementById("div-"+blinkRowId.toString()).style.removeProperty("background-color");
		}
		blinkCount --;
		if (blinkCount > 0) {
			window.setTimeout(function() { blinkRow(); }, 500);
		}
	} catch(e) {
	}
}

//================================================
// Begin here
//================================================
document.addEventListener("DOMContentLoaded", function() {
	backgroundWin = window.top.backgroundWin;
	for (var i=0; i < backgroundWin.tabIconRule.length; i++) {
		addRow(backgroundWin.tabIconRule[i].tabIconURL, backgroundWin.tabIconRule[i].URLRule, backgroundWin.tabIconRule[i].URLRegExp);
	}
	if (window.top.targetRule !== 0) {
		blinkRowId = window.top.targetRule;
		if (blinkRowId < nextRowId) {
			var targetDiv = document.getElementById("div-"+blinkRowId.toString());
			targetDiv.parentNode.scrollTop = targetDiv.offsetTop - targetDiv.parentNode.offsetTop;
			window.setTimeout(function() { blinkRow(); }, 500);
		}
		window.top.targetRule = 0;
	}
	if (window.top.undoTabIconRule.length > 0) {
		document.getElementById("undoDelete").removeAttribute("disabled");
	}
	document.body.addEventListener("dragover", function(event) {
		dragOver(event);
	});
	document.body.addEventListener("drop", function(event) {
		drop(event);
	});
	document.body.addEventListener("dragend", function(event) {
		dragEnd(event);
	});
	document.getElementById("addRule").addEventListener("click", function(event) {
		addNewRule();
	});
	document.getElementById("undoDelete").addEventListener("click", function(event) {
		undoDelete();
	});
	document.getElementById("help").addEventListener("click", function(event) {
		chrome.windows.create({url:"tabIconHelp.xhtml", width:750, height:520, focused:true, incognito:false, type:"popup"});
	});
	document.getElementById("openFile").addEventListener("change", function(event) {
		changeRuleFavicon(event);
	});
	document.getElementById("myEditBox").addEventListener("blur", function(event) {
		closeEditBox();
	});
	document.getElementById("myEditBox").addEventListener("keyup", function(event) {
		event.stopPropagation();
		if (event.keyCode === 13) {
			document.getElementById("myEditBox").blur();
		}
	});
	chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
		if (request.command === "updateTabIconRule") {
			window.location.reload(true);
		}
	});
	resizeContent();
});
