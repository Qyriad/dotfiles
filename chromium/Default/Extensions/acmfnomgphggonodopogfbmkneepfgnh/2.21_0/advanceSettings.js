//================================================================
// Bookmark Favicon Changer by Sonthakit Leelahanon.
// Copyright 2014 Sonthakit Leelahanon. All rights reserved.
//================================================================
"use strict";


var backgroundWin = null;


//================================================
// Timeout
//================================================
function timeoutChange() {
	var newTimeout = document.getElementById("timeoutRange").value;
	var timeoutText = newTimeout.toString() + " second";
	if (newTimeout > 1) {
		timeoutText += "s";
	}
	var timeoutTextElement = document.getElementById("timeoutText");
	timeoutTextElement.removeChild(timeoutTextElement.childNodes[0]);
	timeoutTextElement.appendChild(document.createTextNode(timeoutText));
	backgroundWin.timeout = newTimeout;
	backgroundWin.saveTimeout();
}


//================================================
// Bookmark Bar Name
//================================================
function autoHideBookmarkBarNameChange() {
	if (document.getElementById("autoHideBookmarkBarName").checked) {
		backgroundWin.autoHideBookmarkBarName = true;
		backgroundWin.saveAutoHideBookmarkBarName();
		backgroundWin.hideAllBookmarkBarName();
	} else {
		backgroundWin.autoHideBookmarkBarName = false;
		backgroundWin.saveAutoHideBookmarkBarName();
		backgroundWin.unHideAllBookmarkBarName();
	}
}


//================================================
// Page Action
//================================================
function updatePageActionCheckBoxStatus() {
	document.getElementById("showPageAction0").checked = false;
	document.getElementById("showPageAction1").checked = false;
	document.getElementById("showPageAction2").checked = false;
	document.getElementById("showPageAction" + backgroundWin.showPageAction.toString()).checked = true;
	document.getElementById("pageActionToOptions").checked = backgroundWin.pageActionToOptions;
}
function showPageActionChange(show) {
	backgroundWin.showPageAction = show;
	backgroundWin.saveShowPageAction();
	backgroundWin.resetAllTabPageAction();
}
function pageActionToOptionsChange() {
	backgroundWin.pageActionToOptions = document.getElementById("pageActionToOptions").checked;
	backgroundWin.savePageActionToOptions();
	backgroundWin.resetAllTabPageAction();
}

//================================================
// Begin here
//================================================
document.addEventListener("DOMContentLoaded", function() {
	backgroundWin = window.top.backgroundWin;
	document.getElementById("timeoutRange").value = backgroundWin.timeout;
	timeoutChange();
	document.getElementById("autoHideBookmarkBarName").checked = backgroundWin.autoHideBookmarkBarName;
	updatePageActionCheckBoxStatus();
	document.getElementById("timeoutRange").addEventListener("change", function() {
		timeoutChange();
	});
	document.getElementById("autoHideBookmarkBarName").addEventListener("change", function() {
		autoHideBookmarkBarNameChange();
	});
	document.getElementById("showPageAction0").addEventListener("click", function(event) {
		showPageActionChange(0);
	});
	document.getElementById("showPageAction1").addEventListener("click", function(event) {
		showPageActionChange(1);
	});
	document.getElementById("showPageAction2").addEventListener("click", function(event) {
		showPageActionChange(2);
	});
	document.getElementById("pageActionToOptions").addEventListener("change", function() {
		pageActionToOptionsChange();
	});
	chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
		if (request.command === "updatePageActionCheckBoxStatus") {
			updatePageActionCheckBoxStatus();
		}
	});
});
