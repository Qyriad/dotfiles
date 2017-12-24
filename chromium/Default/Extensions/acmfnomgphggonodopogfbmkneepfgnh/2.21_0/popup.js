//================================================================
// Bookmark Favicon Changer by Sonthakit Leelahanon.
// Copyright 2014 Sonthakit Leelahanon. All rights reserved.
//================================================================
"use strict";


var backgroundWin = null;
var tabId = null;
var pageURL = null;
var originURL = null;
var pageTitle = null;
var URLRules = [];
var busy = false;
var actionData = null;
var beginTime = null;
var xhr = null;
var timer = null;
var popupAutoClosedWhenSelectFile = false;


//================================================
// Status
//================================================
function changeStatus(color, status) {
	var fontStatus = document.getElementById("fontStatus");
	fontStatus.style.color = color;
	fontStatus.removeChild(fontStatus.childNodes[0])
	fontStatus.appendChild(document.createTextNode(status));
}


//================================================
// Favicon manipulate function
//================================================
function changeFavicon(event) {
	busy = true;
	beginTime = (new Date()).getTime();
	changeStatus("yellow", "Changing Favicon...");
	var imageFile = event.target.files[0];
	var reader = new FileReader();
	reader.addEventListener("abort", function(event) {
		changeStatus("red", "Fail - File reading aborted.");
		busy = false;
	});
	reader.addEventListener("error", function(event) {
		changeStatus("red", "Fail - File reading error.");
		busy = false;
	});
	reader.addEventListener("loadend", function(event) {
		var img = new Image();
		img.addEventListener("abort", function(event) {
			changeStatus("red", "Fail - Image loading aborted.");
			busy = false;
		});
		img.addEventListener("error", function(event) {
			changeStatus("red", "Fail - Image error or not support.");
			busy = false;
		});
		img.addEventListener("load", function(event) {
			var pageCustomFavicon = backgroundWin.changeImageToDataURL(event.target);
			var i = backgroundWin.data.pageURL.indexOf(originURL);
			if (i === -1) {
				actionData = {action:"change", pageCustomFavicon:pageCustomFavicon}
			} else {
				if (backgroundWin.data.pageOriginalFavicon[i] === backgroundWin.nullPNG) {
					actionData = {action:"change", pageCustomFavicon:pageCustomFavicon};
				} else {
					var pageOriginalFavicon = backgroundWin.data.pageOriginalFavicon[i];
					actionData = {action:"change", pageCustomFavicon:pageCustomFavicon, pageOriginalFavicon:pageOriginalFavicon};
				}
			}
			setTabFavicon();
		});
		var imageDataURL = backgroundWin.ico16x16Resolution(event.target.result);
		img.src = imageDataURL;
	});
	reader.readAsDataURL(imageFile);
}
function pinFavicon(event) {
	busy = true;
	beginTime = (new Date()).getTime();
	changeStatus("yellow", "Pinning Favicon...");
	var img = new Image();
	img.addEventListener("load", function(event) {
		var pageCustomFavicon = backgroundWin.changeImageToDataURL(event.target);
		var i = backgroundWin.data.pageURL.indexOf(originURL);
		if (i === -1) {
			actionData = {action:"pin", pageCustomFavicon:pageCustomFavicon}
		} else {
			if (backgroundWin.data.pageOriginalFavicon[i] === backgroundWin.nullPNG) {
				actionData = {action:"pin", pageCustomFavicon:pageCustomFavicon};
			} else {
				var pageOriginalFavicon = backgroundWin.data.pageOriginalFavicon[i];
				actionData = {action:"pin", pageCustomFavicon:pageCustomFavicon, pageOriginalFavicon:pageOriginalFavicon};
			}
		}
		setTabFavicon();
	});
	img.src = backgroundWin.getChromeFaviconURL(pageURL);
}
function resetFavicon(event) {
	if (confirm("Are you sure to reset favicon? This cannot be undone.")) {
		busy = true;
		beginTime = (new Date()).getTime();
		changeStatus("yellow", "Resetting Favicon...");
		var i = backgroundWin.data.pageURL.indexOf(originURL);
		if (i !== -1) {
			if (backgroundWin.data.pageOriginalFavicon[i] !== backgroundWin.nullPNG) {
				var pageOriginalFavicon = backgroundWin.data.pageOriginalFavicon[i];
				actionData = {action:"reset", pageCustomFavicon:pageOriginalFavicon};
				setTabFavicon();
				return;
			}
		}
		chrome.tabs.sendMessage(tabId, {command:"getOriginal"}, function(response) {
			if (response) {
				var realFaviconURL = response.originalLinkRelHref;
				changeStatus("yellow", "Loading original favicon...");
				if ((realFaviconURL === null) || (realFaviconURL === "")) {
					var link = document.createElement("a");
					link.href = pageURL;
					if (link.protocol === "file:") {
						actionData = {action:"reset", pageCustomFavicon:backgroundWin.pageDefaultFavicon};
						setTabFavicon();
					} else {
						realFaviconURL = link.protocol + "//" + link.host + "/favicon.ico";
						timer = window.setTimeout(function() {
							if (busy) {
								changeStatus("red", "Fail - Time out loading favicon.");
								busy = false;
								try {
									xhr.abort();
								} catch(e) {
								}
							}
						}, backgroundWin.timeout * 1000);
						xhr = new XMLHttpRequest();
						xhr.open("GET", realFaviconURL, true);
						xhr.responseType = "arraybuffer";
						xhr.addEventListener("abort", function(event) {
							if (busy) {
								try {
									clearTimeout(timer);
								} catch(e) {
								}
								changeStatus("red", "Fail - Favicon loading aborted.");
								busy = false;
							}
							xhr = null;
						});
						xhr.addEventListener("error", function(event) {
							if (busy) {
								try {
									clearTimeout(timer);
								} catch(e) {
								}
								actionData = {action:"reset", pageCustomFavicon:backgroundWin.pageDefaultFavicon};
								setTabFavicon();
							}
							xhr = null;
						});
						xhr.addEventListener("load", function(event) {
							if (busy) {
								try {
									clearTimeout(timer);
								} catch(e) {
								}
								var arrayBuffer = event.target.response;
								if (!arrayBuffer) {
									actionData = {action:"reset", pageCustomFavicon:backgroundWin.pageDefaultFavicon};
									setTabFavicon();
								} else {
									var byteString = "";
									var byteArray = new Uint8Array(arrayBuffer);
									for (var i=0; i < byteArray.byteLength; i++) {
										byteString += String.fromCharCode(byteArray[i]);
									}
									var imageDataURL = "data:;base64," + btoa(byteString);
									imageDataURL = backgroundWin.ico16x16Resolution(imageDataURL);
									var img = new Image();
									img.addEventListener("abort", function(event) {
										changeStatus("red", "Fail - Favicon loading aborted.");
										busy = false;
									});
									img.addEventListener("error", function(event) {
										actionData = {action:"reset", pageCustomFavicon:backgroundWin.pageDefaultFavicon};
										setTabFavicon();
									});
									img.addEventListener("load", function(event) {
										var pageOriginalFavicon = backgroundWin.changeImageToDataURL(event.target);
										actionData = {action:"reset", pageCustomFavicon:pageOriginalFavicon};
										setTabFavicon();
									});
									img.src = imageDataURL;
								}
							}
							xhr = null;
						});
						xhr.send();
					}
				} else {
					var link = document.createElement("a");
					link.href = realFaviconURL;
					if (link.protocol === "data:") {
						var imageDataURL = backgroundWin.ico16x16Resolution(realFaviconURL);
						var img = new Image();
						img.addEventListener("abort", function(event) {
							changeStatus("red", "Fail - Favicon loading aborted.");
							busy = false;
						});
						img.addEventListener("error", function(event) {
							changeStatus("red", "Fail - Favicon loading error.");
							busy = false;
						});
						img.addEventListener("load", function(event) {
							var pageOriginalFavicon = backgroundWin.changeImageToDataURL(event.target);
							actionData = {action:"reset", pageCustomFavicon:pageOriginalFavicon};
							setTabFavicon();
						});
						img.src = imageDataURL;
					} else {
						timer = window.setTimeout(function() {
							if (busy) {
								changeStatus("red", "Fail - Time out loading favicon.");
								busy = false;
								try {
									xhr.abort();
								} catch(e) {
								}
							}
						}, backgroundWin.timeout * 1000);
						xhr = new XMLHttpRequest();
						xhr.open("GET", realFaviconURL, true);
						xhr.responseType = "arraybuffer";
						xhr.addEventListener("abort", function(event) {
							if (busy) {
								try {
									clearTimeout(timer);
								} catch(e) {
								}
								changeStatus("red", "Fail - Loading favicon aborted.");
								busy = false;
							}
							xhr = null;
						});
						xhr.addEventListener("error", function(event) {
							if (busy) {
								try {
									clearTimeout(timer);
								} catch(e) {
								}
								changeStatus("red", "Fail - Loading favicon error.");
								busy = false;
							}
							xhr = null;
						});
						xhr.addEventListener("load", function(event) {
							if (busy) {
								try {
									clearTimeout(timer);
								} catch(e) {
								}
								var arrayBuffer = event.target.response;
								if (!arrayBuffer) {
									changeStatus("red", "Fail - Loading favicon error.");
									busy = false;
								} else {
									var byteString = "";
									var byteArray = new Uint8Array(arrayBuffer);
									for (var i=0; i < byteArray.byteLength; i++) {
										byteString += String.fromCharCode(byteArray[i]);
									}
									var imageDataURL = "data:;base64," + btoa(byteString);
									imageDataURL = backgroundWin.ico16x16Resolution(imageDataURL);
									var img = new Image();
									img.addEventListener("abort", function(event) {
										changeStatus("red", "Fail - Loading favicon aborted.");
										busy = false;
									});
									img.addEventListener("error", function(event) {
										changeStatus("red", "Fail - Loading favicon error.");
										busy = false;
									});
									img.addEventListener("load", function(event) {
										var pageOriginalFavicon = backgroundWin.changeImageToDataURL(event.target);
										actionData = {action:"reset", pageCustomFavicon:pageOriginalFavicon};
										setTabFavicon();
									});
									img.src = imageDataURL;
								}
							}
							xhr = null;
						});
						xhr.send();
					}
				}
			} else {
				changeStatus("red", "Fail - Cannot communicate with page.");
				busy = false;
			}
		});
	}
}
function removeFavicon(event) {
	if (confirm("Are you sure to remove favicon? This cannot be undone.")) {
		busy = true;
		beginTime = (new Date()).getTime();
		changeStatus("yellow", "Removing Favicon...");
		actionData = {action:"remove", pageCustomFavicon:backgroundWin.pageDefaultFavicon};
		setTabFavicon();
	}
}
function exportFavicon() {
	busy = true;
	changeStatus("yellow", "Exporting Favicon...");
	var img = new Image();
	img.addEventListener("load", function(event) {
		var byteString = atob(backgroundWin.changeImageToDataURL(event.target).split(",")[1]);
		var tempArray = [];
		for (var i=0; i < byteString.length; i++) {
			tempArray.push(byteString.charCodeAt(i));
		}
		var blob = new Blob([new Uint8Array(tempArray)], {type:"image/png"});
		var exportFileName = pageTitle.replace(/^\s+|\s+$/g, "");
		if (exportFileName === "") {
			exportFileName = "favicon.png";
		} else {
			exportFileName += ".png";
		}
		var saveAsInput = document.getElementById("saveAs");
		saveAsInput.download = exportFileName;
		saveAsInput.href = window.webkitURL.createObjectURL(blob);
		saveAsInput.click();
		changeStatus("cyan", "Success");
		busy = false;
		window.close();
	});
	img.src = backgroundWin.getChromeFaviconURL(pageURL);
}
function setTabFavicon() {
	var img = new Image();
	img.addEventListener("load", function(event) {
		actionData.currentFavicon = backgroundWin.changeImageToDataURL(event.target);
		changeStatus("yellow", "Observe changing of bookmark favicon. Please wait...");
		chrome.tabs.sendMessage(tabId, {command:"setPageFavicon", tabURL:pageURL, pageCustomFavicon:actionData.pageCustomFavicon});
		window.setTimeout(function() { confirmFavicon(); }, backgroundWin.popupConfirmInterval);
	});
	img.src = backgroundWin.getChromeFaviconURL(originURL);
}
function confirmFavicon() {
	var img = new Image();
	img.addEventListener("load", function(event) {
		var bookmarkFaviconDataURL = backgroundWin.changeImageToDataURL(event.target);
		if ((bookmarkFaviconDataURL === actionData.currentFavicon) && (bookmarkFaviconDataURL !== actionData.pageCustomFavicon)) {
			var elapseTime = (new Date()).getTime() - beginTime;
			if (elapseTime < (backgroundWin.timeout * 1000)) {
				window.setTimeout(function() { confirmFavicon(); }, backgroundWin.popupConfirmInterval);
			} else {
				changeStatus("red", "Fail - Cannot confirm changing of bookmark favicon. Please use extension options page to set bookmark favicon directly.");
				busy = false;
			}
		} else {
			if (actionData.action === "change") {
				if (actionData.pageOriginalFavicon) {
					saveFavicon(originURL, bookmarkFaviconDataURL, actionData.pageOriginalFavicon);
				} else {
					saveFavicon(originURL, bookmarkFaviconDataURL, actionData.currentFavicon);
				}
				backgroundWin.sendAllContentScriptProperFavicon();
			} else if (actionData.action === "pin") {
				if (actionData.pageOriginalFavicon) {
					saveFavicon(originURL, bookmarkFaviconDataURL, actionData.pageOriginalFavicon);
				} else {
					saveFavicon(originURL, bookmarkFaviconDataURL, actionData.currentFavicon);
				}
				backgroundWin.sendAllContentScriptProperFavicon();
			} else if (actionData.action === "reset") {
				deleteFavicon(originURL);
				backgroundWin.sendAllContentScriptProperFavicon();
			} else if (actionData.action === "remove") {
				deleteFavicon(originURL);
				backgroundWin.sendContentScriptRemoveFavicon(originURL);
				if (pageURL !== originURL) {
					backgroundWin.sendContentScriptRemoveFavicon(pageURL);
				}
			}
			chrome.runtime.sendMessage({command:"updateList", pageURL:originURL, pageCustomFavicon:bookmarkFaviconDataURL});
			changeStatus("cyan", "Success");
			busy = false;
			window.close();
		}
	});
	img.src = backgroundWin.getChromeFaviconURL(originURL);
}


//================================================
// Tab Icon
//================================================
function openEditTabIconFile(event) {
	busy = true;
	changeStatus("yellow", "Reading tab icon file...");
	var imageFile = event.target.files[0];
	var reader = new FileReader();
	reader.addEventListener("abort", function(event) {
		changeStatus("red", "Fail - File reading aborted.");
		busy = false;
	});
	reader.addEventListener("error", function(event) {
		changeStatus("red", "Fail - File reading error.");
		busy = false;
	});
	reader.addEventListener("loadend", function(event) {
		var img = new Image();
		img.addEventListener("abort", function(event) {
			changeStatus("red", "Fail - Image loading aborted.");
			busy = false;
		});
		img.addEventListener("error", function(event) {
			changeStatus("red", "Fail - Image error or not support.");
			busy = false;
		});
		img.addEventListener("load", function(event) {
			var tabIconURL = backgroundWin.changeImageToDataURL(event.target);
			document.getElementById("editTabIconImage").src = tabIconURL;
			var URLRule = document.getElementById("editTabIconURLRule").getAttribute("data-URLRule");
			for (var i=0; i < backgroundWin.tabIconRule.length; i++) {
				if (backgroundWin.tabIconRule[i].URLRule === URLRule) {
					backgroundWin.tabIconRule[i].tabIconURL = tabIconURL;
					backgroundWin.saveTabIconRule();
					backgroundWin.sendAllContentScriptProperFavicon();
					chrome.runtime.sendMessage({command:"updateTabIconRule"});
					changeStatus("cyan", "Success");
					busy = false;
					window.close();
					return;
				}
			}
			changeStatus("red", "Fail - This rule had been deleted.");
			busy = false;
		});
		var imageDataURL = backgroundWin.ico16x16Resolution(event.target.result);
		img.src = imageDataURL;
	});
	reader.readAsDataURL(imageFile);
}
function deleteRule() {
	if (confirm("Are you sure to delete this tab icon rule? This cannot be undone.")) {
		busy = true;
		var URLRule = document.getElementById("editTabIconURLRule").getAttribute("data-URLRule");
		for (var i=0; i < backgroundWin.tabIconRule.length; i++) {
			if (backgroundWin.tabIconRule[i].URLRule === URLRule) {
				backgroundWin.tabIconRule.splice(i, 1);
				backgroundWin.saveTabIconRule();
				backgroundWin.sendAllContentScriptProperFavicon();
				chrome.runtime.sendMessage({command:"updateTabIconRule"});
				changeStatus("cyan", "Success");
				busy = false;
				window.close();
				return;
			}
		}
		changeStatus("red", "Fail - This rule had been deleted.");
		busy = false;
	}
}
function exportRule() {
	busy = true;
	var tabIconURL = document.getElementById("editTabIconImage").src;
	var byteString = atob((tabIconURL).split(",")[1]);
	var tempArray = [];
	for (var i=0; i < byteString.length; i++) {
		tempArray.push(byteString.charCodeAt(i));
	}
	var blob = new Blob([new Uint8Array(tempArray)], {type:"image/png"});
	var exportFileName = "icon.png";
	var saveAsInput = document.getElementById("saveAs");
	saveAsInput.download = exportFileName;
	saveAsInput.href = window.webkitURL.createObjectURL(blob);
	saveAsInput.click();
	changeStatus("cyan", "Success");
	busy = false;
	window.close();
}
function openAddTabIconFile(event) {
	busy = true;
	changeStatus("yellow", "Reading tab icon file...");
	var imageFile = event.target.files[0];
	var reader = new FileReader();
	reader.addEventListener("abort", function(event) {
		changeStatus("red", "Fail - File reading aborted.");
		busy = false;
	});
	reader.addEventListener("error", function(event) {
		changeStatus("red", "Fail - File reading error.");
		busy = false;
	});
	reader.addEventListener("loadend", function(event) {
		var img = new Image();
		img.addEventListener("abort", function(event) {
			changeStatus("red", "Fail - Image loading aborted.");
			busy = false;
		});
		img.addEventListener("error", function(event) {
			changeStatus("red", "Fail - Image error or not support.");
			busy = false;
		});
		img.addEventListener("load", function(event) {
			var tabIconURL = backgroundWin.changeImageToDataURL(event.target);
			document.getElementById("addTabIconImage").src = tabIconURL;
			document.getElementById("addTabIconImage").setAttribute("data-tabIconURL", tabIconURL);
			changeStatus("black", "Ready");
			busy = false;
		});
		var imageDataURL = backgroundWin.ico16x16Resolution(event.target.result);
		img.src = imageDataURL;
	});
	reader.readAsDataURL(imageFile);
}
function addRule() {
	busy = true;
	var tabIconURL = document.getElementById("addTabIconImage").getAttribute("data-tabIconURL");
	if (tabIconURL === "") {
		changeStatus("red", "Fail - You don't choose any tab icon.");
	} else {
		var inputs = document.getElementsByTagName("input");
		for (var i=0; i < inputs.length; i++) {
			if (inputs[i].id.indexOf("-") !== -1) {
				if (inputs[i].checked) {
					var URLRule = inputs[i].getAttribute("data-URLRule");
					var URLRegExp = backgroundWin.ruleToRegExp(URLRule);
					backgroundWin.tabIconRule.push({tabIconURL:tabIconURL, URLRule:URLRule, URLRegExp:URLRegExp});
					backgroundWin.saveTabIconRule();
					backgroundWin.sendAllContentScriptProperFavicon();
					chrome.runtime.sendMessage({command:"updateTabIconRule"});
					changeStatus("cyan", "Success");
					busy = false;
					window.close();
					return;
				}
			}
		}
		changeStatus("red", "Fail - You don't select any rule.");
	}
	busy = false;
}
function chooseIconAndAddRule() {
	var inputs = document.getElementsByTagName("input");
	for (var i=0; i < inputs.length; i++) {
		if (inputs[i].id.indexOf("-") !== -1) {
			if (inputs[i].checked) {
				var URLRule = inputs[i].getAttribute("data-URLRule");
				chrome.tabs.sendMessage(tabId, {command:"popupRescueOKAddRule", URLRule:URLRule});
				window.close();
			}
		}
	}
	changeStatus("red", "Fail - You don't select any rule.");
}


//================================================
// Begin here
//================================================
document.addEventListener("DOMContentLoaded", function() {
	chrome.runtime.getBackgroundPage(function(backgroundPage) {
		backgroundWin = backgroundPage;
		var search = window.location.search;
		tabId = Number(search.substr(1));
		if (parseInt(navigator.userAgent.match(/Chrom(e|ium)\/([0-9]+)\./)[2]) >= 32) {
			popupAutoClosedWhenSelectFile = true;
		} else if (navigator.appVersion.indexOf("Mac") !== -1) {
			popupAutoClosedWhenSelectFile = true;
		}
		chrome.tabs.get(tabId, function(tab) {
			pageURL = tab.url;
			originURL = pageURL;
			pageTitle = tab.title;
			if (popupAutoClosedWhenSelectFile) {
				document.getElementById("changeFaviconCell").addEventListener("click", function(event) {
					if (!busy) {
						chrome.tabs.sendMessage(tabId, {command:"popupRescueChangeFavicon", originURL:originURL, pageURL:pageURL});
						window.close();
					}
				});
			} else {
				document.getElementById("changeFaviconCell").addEventListener("click", function(event) {
					if (!busy) {
						document.getElementById("changeFaviconInput").value = "";
						document.getElementById("changeFaviconInput").click();
					}
				});
			}
			document.getElementById("changeFaviconInput").addEventListener("change", function(event) {
				if (!busy) {
					changeFavicon(event);
				}
			});
			document.getElementById("pinFaviconCell").addEventListener("click", function(event) {
				if (!busy) {
					pinFavicon();
				}
			});
			document.getElementById("resetFaviconCell").addEventListener("click", function(event) {
				if (!busy) {
					resetFavicon();
				}
			});
			document.getElementById("removeFaviconCell").addEventListener("click", function(event) {
				if (!busy) {
					removeFavicon();
				}
			});
			document.getElementById("exportFaviconCell").addEventListener("click", function(event) {
				if (!busy) {
					exportFavicon();
				}
			});
			document.getElementById("exportOnlyFaviconCell").addEventListener("click", function(event) {
				if (!busy) {
					exportFavicon();
				}
			});
			if (popupAutoClosedWhenSelectFile) {
				document.getElementById("changeIconEditCell").addEventListener("click", function(event) {
					if (!busy) {
						var URLRule = document.getElementById("editTabIconURLRule").getAttribute("data-URLRule");
						chrome.tabs.sendMessage(tabId, {command:"popupRescueChangeIconEdit", URLRule:URLRule});
						window.close();
					}
				});
			} else {
				document.getElementById("changeIconEditCell").addEventListener("click", function(event) {
					if (!busy) {
						document.getElementById("openEditTabIconFile").click();
					}
				});
			}
			document.getElementById("openEditTabIconFile").addEventListener("change", function(event) {
				if (!busy) {
					openEditTabIconFile(event);
				}
			});
			document.getElementById("OKDeleteRule").addEventListener("click", function(event) {
				if (!busy) {
					deleteRule();
				}
			});
			document.getElementById("OKExportRule").addEventListener("click", function(event) {
				if (!busy) {
					exportRule();
				}
			});
			if (popupAutoClosedWhenSelectFile) {
				document.getElementById("OKAddRule").innerText = "Change icon and add rule";
				document.getElementById("changeIconAddCell").setAttribute("class", "hide");
				document.getElementById("OKAddRule").addEventListener("click", function(event) {
					if (!busy) {
						chooseIconAndAddRule();
					}
				});
			} else {
				document.getElementById("changeIconAddCell").addEventListener("click", function(event) {
					if (!busy) {
						document.getElementById("openAddTabIconFile").click();
					}
				});
				document.getElementById("openAddTabIconFile").addEventListener("change", function(event) {
					if (!busy) {
						openAddTabIconFile(event);
					}
				});
				document.getElementById("OKAddRule").addEventListener("click", function(event) {
					if (!busy) {
						addRule();
					}
				});
			}
			document.getElementById("pageActionToOptions").addEventListener("click", function(event) {
				backgroundWin.pageActionToOptions = document.getElementById("pageActionToOptions").checked;
				backgroundWin.savePageActionToOptions();
				backgroundWin.resetAllTabPageAction();
				chrome.runtime.sendMessage({command:"updatePageActionCheckBoxStatus"});
			});
			document.getElementById("showPageAction").addEventListener("click", function(event) {
				backgroundWin.pageActionClick("AdvanceSettings");
				window.close();
			});
			document.getElementById("openOptions").addEventListener("click", function(event) {
				backgroundWin.pageActionClick(pageURL);
				window.close();
			});
			window.addEventListener("resize", function() {
				var newWidth = window.innerWidth;
				document.getElementById("tableFavicon").style.width = (newWidth - 28).toString() + "px";
				document.getElementById("tableExportOnly").style.width = (newWidth - 28).toString() + "px";
				document.getElementById("tableEditTabIcon").style.width = (newWidth - 28).toString() + "px";
				document.getElementById("tableAddTabIcon").style.width = (newWidth - 28).toString() + "px";
				document.getElementById("editBlankTd").style.width = (newWidth - 338).toString() + "px";
				document.getElementById("addBlankTd").style.width = (newWidth - 259).toString() + "px";
			});
			if (backgroundWin.banned) {
				document.getElementById("banned").removeAttribute("class");
			} else {
				var link = document.createElement("a");
				link.href = pageURL;
				var URLGrowth = link.protocol + "//" + link.host;
				var URLPathName = link.pathname;
				var i = 0;
				while (i !== -1) {
					URLGrowth = URLGrowth + URLPathName.substr(0, i + 1);
					URLRules.unshift(URLGrowth + "*");
					URLPathName = URLPathName.substr(i + 1);
					i = URLPathName.indexOf("/");
				}
				if (URLPathName === "") {
					URLRules.unshift(pageURL);
				} else {
					URLGrowth = URLGrowth + URLPathName;
					URLRules.unshift(URLGrowth);
					if (URLGrowth !== pageURL) {
						URLRules.unshift(URLGrowth + "*");
						URLRules.unshift(pageURL);
					}
				}
				var root = document.getElementById("root");
				for (var i=0; i < URLRules.length; i++) {
					var input = document.createElement("input");
					input.type = "radio";
					input.name = "URLRule";
					input.id = "radio-" + i.toString();
					input.setAttribute("data-URLRule", URLRules[i]);
					var font = document.createElement("font");
					font.id = "font-" + i.toString();
					font.appendChild(document.createTextNode(URLRules[i]));
					var div = document.createElement("div");
					div.id = "div-" + i.toString();
					div.appendChild(input);
					div.appendChild(font);
					div.setAttribute("class", "rule");
					root.appendChild(div);
				}
				document.getElementById("addTabIconImage").src = backgroundWin.nullPNG;
				chrome.bookmarks.search(pageURL, function(results) {
					if (results) {
						for (var j=0; j < results.length; j++) {
							if (results[j].url === pageURL) {
								var i = backgroundWin.data.pageURL.indexOf(pageURL);
								if (i !== -1) {
									document.getElementById("bookmarkedAndCustomFavicon").removeAttribute("class");
									document.getElementById("bookmarkFavicon").removeAttribute("class");
									document.getElementById("canChange").removeAttribute("class");
									document.getElementById("addRule").removeAttribute("class");
									document.getElementById("status").removeAttribute("class");
									return;
								} else {
									var modifiedURL = escape(unescape(pageURL));
									for (var i=0; i < backgroundWin.tabIconRule.length; i++) {
										if ((new RegExp(backgroundWin.tabIconRule[i].URLRegExp, "")).test(modifiedURL)) {
											var URLRule = backgroundWin.tabIconRule[i].URLRule;
											var tabIconURL = backgroundWin.tabIconRule[i].tabIconURL;
											document.getElementById("bookmarkedAndTabIcon").removeAttribute("class");
											document.getElementById("bookmarkFavicon").removeAttribute("class");
											document.getElementById("pinFaviconCell").removeAttribute("class");
											document.getElementById("canChange").removeAttribute("class");
											document.getElementById("editRule").removeAttribute("class");
											document.getElementById("editTabIconURLRule").setAttribute("data-URLRule", URLRule);
											document.getElementById("editTabIconURLRule").appendChild(document.createTextNode(URLRule));
											document.getElementById("editTabIconImage").src = tabIconURL;
											document.getElementById("addRule").removeAttribute("class");
											document.getElementById("status").removeAttribute("class");
											return;
										}
									}
									document.getElementById("bookmarked").removeAttribute("class");
									document.getElementById("bookmarkFavicon").removeAttribute("class");
									document.getElementById("pinFaviconCell").removeAttribute("class");
									document.getElementById("canChange").removeAttribute("class");
									document.getElementById("addRule").removeAttribute("class");
									document.getElementById("status").removeAttribute("class");
									return;
								}
							}
						}
					}
					deleteFavicon(pageURL);
					var j = backgroundWin.redirectData.toURL.indexOf(pageURL);
					if (j !== -1) {
						originURL = backgroundWin.redirectData.fromURL[j];
						var k = backgroundWin.data.pageURL.indexOf(originURL);
						if (k !== -1) {
							document.getElementById("redirectAndCustomFavicon").removeAttribute("class");
							document.getElementById("bookmarkFavicon").removeAttribute("class");
							document.getElementById("possiblyChange").removeAttribute("class");
							document.getElementById("addRule").removeAttribute("class");
							document.getElementById("status").removeAttribute("class");
							return;
						} else {
							var modifiedURL = escape(unescape(pageURL));
							for (var i=0; i < backgroundWin.tabIconRule.length; i++) {
								if ((new RegExp(backgroundWin.tabIconRule[i].URLRegExp, "")).test(modifiedURL)) {
									var URLRule = backgroundWin.tabIconRule[i].URLRule;
									var tabIconURL = backgroundWin.tabIconRule[i].tabIconURL;
									document.getElementById("redirectAndTabIcon").removeAttribute("class");
									document.getElementById("bookmarkFavicon").removeAttribute("class");
									document.getElementById("pinFaviconCell").removeAttribute("class");
									document.getElementById("possiblyChange").removeAttribute("class");
									document.getElementById("editRule").removeAttribute("class");
									document.getElementById("editTabIconURLRule").setAttribute("data-URLRule", URLRule);
									document.getElementById("editTabIconURLRule").appendChild(document.createTextNode(URLRule));
									document.getElementById("editTabIconImage").src = tabIconURL;
									document.getElementById("addRule").removeAttribute("class");
									document.getElementById("status").removeAttribute("class");
									return;
								}
							}
							document.getElementById("redirect").removeAttribute("class");
							document.getElementById("bookmarkFavicon").removeAttribute("class");
							document.getElementById("pinFaviconCell").removeAttribute("class");
							document.getElementById("possiblyChange").removeAttribute("class");
							document.getElementById("addRule").removeAttribute("class");
							document.getElementById("status").removeAttribute("class");
							return;
						}
					} else {
						var modifiedURL = escape(unescape(pageURL));
						for (var i=0; i < backgroundWin.tabIconRule.length; i++) {
							if ((new RegExp(backgroundWin.tabIconRule[i].URLRegExp, "")).test(modifiedURL)) {
								var URLRule = backgroundWin.tabIconRule[i].URLRule;
								var tabIconURL = backgroundWin.tabIconRule[i].tabIconURL;
								document.getElementById("tabIcon").removeAttribute("class");
								document.getElementById("editRule").removeAttribute("class");
								document.getElementById("editTabIconURLRule").setAttribute("data-URLRule", URLRule);
								document.getElementById("editTabIconURLRule").appendChild(document.createTextNode(URLRule));
								document.getElementById("editTabIconImage").src = tabIconURL;
								document.getElementById("addRule").removeAttribute("class");
								document.getElementById("status").removeAttribute("class");
								return;
							}
						}
						document.getElementById("normalPage").removeAttribute("class");
						document.getElementById("exportOnly").removeAttribute("class");
						document.getElementById("addRule").removeAttribute("class");
						document.getElementById("status").removeAttribute("class");
						return;
					}
				});
			}
		})
	});
});
