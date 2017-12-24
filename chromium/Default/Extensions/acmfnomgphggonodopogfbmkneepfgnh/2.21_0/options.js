//================================================================
// Bookmark Favicon Changer by Sonthakit Leelahanon.
// Copyright 2014 Sonthakit Leelahanon. All rights reserved.
//================================================================
"use strict";


var backgroundWin = null;
var logWin = null;
var folderWin = null;
var bookmarkWin = null;
var targetFolder = null;
var targetRule = null;
var targetBookmark = "0";
var bookmarkWinScrollTop = 0;
var expandFolder = [];
var undoDeleteHistory = [];
var undoTabIconRule = [];


//================================================
// general function
//================================================
function resizeIFrame() {
	var rect = document.getElementById("mainIFrame").getBoundingClientRect();
	var newHeight = window.innerHeight - rect.top - 20;
	if (newHeight < 200) {newHeight = 200;}
	document.getElementById("mainIFrame").height = newHeight;
	var rect = document.getElementById("logIFrame").getBoundingClientRect();
	var newWidth = window.innerWidth - rect.left - 20;
	if (newWidth < 200) {newWidth = 200;}
	document.getElementById("logIFrame").width = newWidth;
}
function saveAs(fileName, byteString, mimeType) {
	var tempArray = [];
	for (var i=0; i < byteString.length; i++) {
		tempArray.push(byteString.charCodeAt(i));
	}
	var blob = new Blob([new Uint8Array(tempArray)], {type:mimeType});
	var saveAsInput = document.getElementById("saveAs");
	saveAsInput.download = fileName;
	saveAsInput.href = window.webkitURL.createObjectURL(blob);
	saveAsInput.click();
}
function bannedAlert() {
	alert('Oops! "Bookmark Favicon Changer" is banned!\n\nDue to excessive bookmark manipulation, browser has inhibited some functions of "Bookmark Favicon Changer" especially making change on bookmarks. This is a protective mechanism of browser. Because bookmarks may need to go online to sync, excessive bookmark manipulation can load the sync server which looks like an attack.\n\nYou need to restart browser to make "Bookmark Favicon Changer" work again.');
}


//================================================
// Zip function
//================================================
var CDFH = null;
var zipFile = null;
var totalFile = null;
function numberToByteString(input, numberOfByte) {
	var result = "";
	var tempDWord = (input >>> 0);
	for (var i=0; i < numberOfByte; i++) {
		result += String.fromCharCode(tempDWord & 0xFF);
		tempDWord = tempDWord >>> 8
	}
	return result;
}
function newZip() {
	CDFH = "";
	zipFile = "";
	totalFile = 0;
}
function addZipFileUncompress(fileName, fileByteString) {
	var LFH = "\x50\x4B\x03\x04\x0A\x00\x00\x00\x00\x00";
	CDFH += "\x50\x4B\x01\x02\x0A\x00\x0A\x00\x00\x00\x00\x00";
	var currentTime = new Date();
	var dosTime = (currentTime.getHours() * 2048) + (currentTime.getMinutes() * 32) + Math.floor(currentTime.getSeconds() / 2);
	var dosDate = ((currentTime.getFullYear() - 1980) * 512) + ((currentTime.getMonth() + 1) * 32) + currentTime.getDate();
	var tempByteString = numberToByteString(dosTime, 2) + numberToByteString(dosDate, 2) + numberToByteString(crc32(fileByteString), 4);
	var fileSizeByteString = numberToByteString(fileByteString.length, 4);
	tempByteString += fileSizeByteString + fileSizeByteString + numberToByteString(fileName.length, 2) + "\x00\x00";
	LFH += tempByteString;
	CDFH += tempByteString + "\x00\x00\x00\x00\x01\x00\x20\x00\x00\x00";
	CDFH += numberToByteString(zipFile.length, 4);
	LFH += fileName;
	CDFH += fileName;
	zipFile += LFH;
	zipFile += fileByteString;
	totalFile ++;
	return;
}
function getZip() {
	var EOCDR = "\x50\x4B\x05\x06\x00\x00\x00\x00";
	var totalFileByteString = numberToByteString(totalFile, 2);
	EOCDR += totalFileByteString + totalFileByteString;
	EOCDR += numberToByteString(CDFH.length, 4);
	EOCDR += numberToByteString(zipFile.length, 4);
	EOCDR += "\x00\x00";
	var completeZip = zipFile + CDFH + EOCDR;
	CDFH = null;
	zipFile = null;
	totalFile = null;
	return completeZip;
}


//================================================
// Favicon manipulate function
//================================================
var exportActive = false;
var exportPageURLs = null;
var exportTabIcons = null;
var exportFileCount = null;
var digit = null;
function changeFavicon(pageURL, pageCustomFavicon, pageOriginalFavicon) {
	if (pageOriginalFavicon === backgroundWin.nullPNG) {
		var i = backgroundWin.data.pageURL.indexOf(pageURL);
		if (i === -1) {
			(function(pageURL, pageCustomFavicon) {
				var img = new Image();
				img.addEventListener("load", function(event) {
					var newPageOriginalFavicon = backgroundWin.changeImageToDataURL(event.target);
					popupData.push({action:"change", pageURL:pageURL, pageCustomFavicon:pageCustomFavicon, pageOriginalFavicon:newPageOriginalFavicon});
					totalJob ++;
					if (popupData.length === 1) {
						window.setTimeout(function() { popupInit(); }, 0);
					}
				});
				img.src = backgroundWin.getChromeFaviconURL(pageURL);
			})(pageURL, pageCustomFavicon);
			return;
		} else {
			if (backgroundWin.data.pageOriginalFavicon[i] === backgroundWin.nullPNG) {
				(function(pageURL, pageCustomFavicon) {
					var img = new Image();
					img.addEventListener("load", function(event) {
						var newPageOriginalFavicon = backgroundWin.changeImageToDataURL(event.target);
						popupData.push({action:"change", pageURL:pageURL, pageCustomFavicon:pageCustomFavicon, pageOriginalFavicon:newPageOriginalFavicon});
						totalJob ++;
						if (popupData.length === 1) {
							window.setTimeout(function() { popupInit(); }, 0);
						}
					});
					img.src = backgroundWin.getChromeFaviconURL(pageURL);
				})(pageURL, pageCustomFavicon);
				return;
			}
			var newPageOriginalFavicon = backgroundWin.data.pageOriginalFavicon[i];
		}
	} else {
		var newPageOriginalFavicon = pageOriginalFavicon;
	}
	popupData.push({action:"change", pageURL:pageURL, pageCustomFavicon:pageCustomFavicon, pageOriginalFavicon:newPageOriginalFavicon});
	totalJob ++;
	if (popupData.length === 1) {
		window.setTimeout(function() { popupInit(); }, 0);
	}
}
function pinFavicon(pageURL) {
	(function(pageURL) {
		var img = new Image();
		img.addEventListener("load", function(event) {
			var pageCustomFavicon = backgroundWin.changeImageToDataURL(event.target);
			var newPageOriginalFavicon = pageCustomFavicon;
			var i = backgroundWin.data.pageURL.indexOf(pageURL);
			if (i !== -1) {
				if (backgroundWin.data.pageOriginalFavicon[i] !== backgroundWin.nullPNG) {
					newPageOriginalFavicon = backgroundWin.data.pageOriginalFavicon[i];
				}
			}
			popupData.push({action:"pin", pageURL:pageURL, pageCustomFavicon:pageCustomFavicon, pageOriginalFavicon:newPageOriginalFavicon});
			totalJob ++;
			if (popupData.length === 1) {
				window.setTimeout(function() { popupInit(); }, 0);
			}
		});
		img.src = backgroundWin.getChromeFaviconURL(pageURL);
	})(pageURL);
}
function resetFavicon(pageURL) {
	var pageOriginalFavicon = backgroundWin.nullPNG;
	var i = backgroundWin.data.pageURL.indexOf(pageURL);
	if (i !== -1) {
		pageOriginalFavicon = backgroundWin.data.pageOriginalFavicon[i];
	}
	popupData.push({action:"reset", pageURL:pageURL, pageCustomFavicon:pageOriginalFavicon});
	totalJob ++;
	if (popupData.length === 1) {
		window.setTimeout(function() { popupInit(); }, 0);
	}
}
function removeFavicon(pageURL) {
	popupData.push({action:"remove", pageURL:pageURL, pageCustomFavicon:backgroundWin.pageDefaultFavicon});
	totalJob ++;
	if (popupData.length === 1) {
		window.setTimeout(function() { popupInit(); }, 0);
	}
}
function exportSingleFavicon(pageURL, exportFileName) {
	exportActive = true;
	logWin.log("black", 'Export favicon at "' + pageURL + '"');
	var img = new Image();
	img.addEventListener("load", function(event) {
		var byteString = atob(backgroundWin.changeImageToDataURL(event.target).split(",")[1]);
		logWin.log("blue", "Success.");
		saveAs(exportFileName, byteString, "image/png");
		exportActive = false;
	});
	img.src = backgroundWin.getChromeFaviconURL(pageURL);
}
function exportSingleIcon(tabIcon) {
	exportActive = true;
	logWin.log("black", 'Export tab icon');
	var byteString = atob(tabIcon.split(",")[1]);
	logWin.log("blue", "Success.");
	saveAs("icon.png", byteString, "image/png");
	exportActive = false;
}
function exportMultipleFavicon(pageURLs, tabIcons) {
	exportActive = true;
	exportPageURLs = pageURLs.slice();
	exportTabIcons = tabIcons.slice();
	exportFileCount = 0;
	digit = Math.floor(Math.log(exportPageURLs.length + exportTabIcons.length)/Math.log(10)) + 1;
	newZip();
	zipNextExportFavicon();
}
function zipNextExportFavicon() {
	if (exportPageURLs.length !== 0) {
		var pageURL = exportPageURLs[0];
		logWin.log("black", 'Export favicon at "' + pageURL + '"');
		var img = new Image();
		img.addEventListener("load", function(event) {
			exportFileCount ++;
			var digitName = ("000000000" + exportFileCount.toString()).substr(-digit, digit) + ".png";
			var byteString = atob(backgroundWin.changeImageToDataURL(event.target).split(",")[1]);
			addZipFileUncompress(digitName, byteString);
			logWin.log("blue", "Success.");
			exportPageURLs.shift();
			zipNextExportFavicon();
		});
		img.src = backgroundWin.getChromeFaviconURL(pageURL);
	} else {
		if (exportTabIcons.length !== 0) {
			logWin.log("black", 'Export tab icons');
			do {
				exportFileCount ++;
				var digitName = ("000000000" + exportFileCount.toString()).substr(-digit, digit) + ".png";
				var byteString = atob(exportTabIcons[0].split(",")[1]);
				addZipFileUncompress(digitName, byteString);
				exportTabIcons.shift();
			} while (exportTabIcons.length > 0)
			logWin.log("blue", "Success.");
		}
		var byteString = getZip();
		if (exportFileCount > 0) {
			saveAs("favicon.zip", byteString, "application/zip");
		}
		exportActive = false;
	}
}


//================================================
// popup management
//================================================
var popupData = [];
var popupWinId = 0;
var popupTabId = 0;
var sessionId = 0;
var totalJob = 0;
var finishJob = 0;
var timer = null;
var xhr = null;
var initURL = "data:text/html;base64," + window.btoa('<html><body><center><h2>Bookmark Favicon Changer</h2><b>Close this window to abort</b><br><br><progress value="0" max="1"></progress>&nbsp;0%</center></body></html>');
var finishURL = "data:text/html;base64," + window.btoa('<html><body><center><h2>Bookmark Favicon Changer</h2><b>Close this window to abort</b><br><br><progress value="1" max="1"></progress>&nbsp;100%</center></body></html>');
var onBeforeRequest = function(details) {
	if (details.url === finishURL) {
		return {cancel:false};
	} else if (details.url === popupData[0].pageURL) {
		var redirectURL = popupData[0].pageRedirectURL;
		return {redirectUrl:redirectURL};
	} else if (details.url === popupData[0].pageRedirectURL) {
		return {cancel:false};
	} else if (details.url === initURL) {
		return {cancel:false};
	} else if (details.tabId !== popupTabId) {
		return {cancel:true};
	} else {
		return {cancel:true};
	}
}
var onErrorOccurred = function(details) {
	if (details.tabId === popupTabId) {
		if (popupData[0]) {
			var checkId = popupData[0].id;
			if (checkId === sessionId) {
				if ((details.url === popupData[0].pageURL) || (details.url === popupData[0].pageRedirectURL) || (details.url === initURL) || (details.url === finishURL)) {
					logWin.log("red", 'Serous internal error - Error on generating dataURL page at "' + details.url + '". Please contact extension developer.');
					window.setTimeout(function() { chrome.windows.remove(popupWinId); }, 0);
				} else {
					if (popupData[0].onlineMode) {
						logWin.log("red", 'Fail - Loading webpage return error.');
					} else {
						logWin.log("red", 'Fail - Unknow error at "' + details.url + '". Please contact extension developer.');
					}
					sessionId ++;
					var id = sessionId;
					(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
				}
			}
		}
	}
}
var onTabUpdated = function(tabId, changeInfo, tab) {
	if (tabId === popupTabId) {
		if ((changeInfo.status === "complete") && (tab.url === finishURL)) {
			window.setTimeout(function() { chrome.windows.remove(popupWinId); }, 0);
		} else if (popupData[0]) {
			if (popupData[0].onlineMode) {
				if (changeInfo.status === "complete") {
					var tabURL = tab.url;
					if (tabURL !== popupData[0].pageRedirectURL) {
						(function(tabURL) {
							chrome.tabs.sendMessage(tabId, {command:"getOriginal"}, function(response) {
								if (response) {
									chrome.tabs.sendMessage(tabId, {command:"setPageFavicon", tabURL:tabURL, pageCustomFavicon:popupData[0].pageCustomFavicon});
									if (tabURL === popupData[0].onlineMode) {
										sessionId ++;
										var id = sessionId;
										(function(id) {window.setTimeout(function() { popupConfirm(id); }, 0);})(id);
									}
								} else {
									sessionId ++;
									var id = sessionId;
									logWin.log("red", 'Fail - Browser inhibits modification of this page due to security.');
									chrome.tabs.update(popupTabId, {url: popupData[0].pageRedirectURL});
									(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
								}
							});
						})(tabURL);
					}
				}
			} else {
				var checkId = popupData[0].id;
				if (checkId === sessionId) {
					if ((changeInfo.status === "complete") && (tab.url === popupData[0].pageRedirectURL)) {
						sessionId ++;
						var id = sessionId;
						(function(id) {window.setTimeout(function() { popupConfirm(id); }, 0);})(id);
					} else if ((changeInfo.status === "loading") && (tab.url === popupData[0].pageURL)) {
						logWin.log("brown", 'Do not have permission on offline mode for page "' + popupData[0].pageURL + '".');
						logWin.log("green", 'Try online mode...');
						popupData[0].onlineMode = tab.url;
					} else if ((tab.url !== initURL) && (tab.url !== popupData[0].pageRedirectURL)) {
						sessionId ++;
						var id = sessionId;
						logWin.log("red", 'Fail - Unexpected URL on tab. Please contact extension developer.');
						(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
					}
				}
			}
		}
	}
}
var onTabRemoved = function(tabId, removeInfo) {
	if (tabId === popupTabId) {
		if (!removeInfo.isWindowClosing) {
			window.setTimeout(function() { chrome.windows.remove(popupWinId); }, 0);
		}
	}
}
var onTabDetached = function(tabId, detachInfo) {
	if (tabId === popupTabId) {
		window.setTimeout(function() { chrome.windows.remove(popupWinId); }, 0);
	}
}
var onTabReplaced = function(addedTabId, removedTabId) {
	if (removedTabId === popupTabId) {
		window.setTimeout(function() { chrome.windows.remove(popupWinId); }, 0);
	}
}
var onWindowRemoved = function(windowId) {
	if (windowId === popupWinId) {
		sessionId ++;
		try {
			clearTimeout(timer);
		} catch(e) {
		}
		try {
			xhr.abort();
		} catch(e) {
		}
		xhr = null;
		if (popupData.length !== 0) {
			logWin.log("red", "Fail - Popup window was closed. Terminate all residual jobs.");
		}
		popupData = [];
		popupWinId = 0;
		popupTabId = 0;
		backgroundWin.popupTabId = 0;
		chrome.webRequest.onBeforeRequest.removeListener(onBeforeRequest, {urls:["<all_urls>"], windowId: popupWinId}, ["blocking"]);
		chrome.webRequest.onErrorOccurred.removeListener(onErrorOccurred, {urls: ["<all_urls>"], windowId: popupWinId});
		chrome.tabs.onUpdated.removeListener(onTabUpdated);
		chrome.tabs.onRemoved.removeListener(onTabRemoved);
		chrome.tabs.onDetached.removeListener(onTabDetached);
		chrome.tabs.onReplaced.removeListener(onTabReplaced);
		chrome.windows.onRemoved.removeListener(onWindowRemoved);
		document.getElementById("modalGlass").setAttribute("class", "hide");
		document.getElementById("dialogAskForCreateBookmark").setAttribute("class", "hide");
	}
}
var userAnswerForCreateBookmark = null;
var askForCreateBookmarkId = null;
function askForCreateBookmark(id, pageURL) {
	askForCreateBookmarkId = id;
	if (userAnswerForCreateBookmark === "yesToAll") {
		answerForCreateBookmark("createYes");
	} else if (userAnswerForCreateBookmark === "noToAll") {
		answerForCreateBookmark("createNo");
	} else {
		var createURLElement = document.getElementById("createURL");
		createURLElement.removeChild(createURLElement.childNodes[0]);
		createURLElement.appendChild(document.createTextNode(pageURL));
		document.getElementById("modalGlass").setAttribute("class", "modalGlass");
		document.getElementById("dialogAskForCreateBookmark").setAttribute("class", "dialogAskModal");
	}
}
function answerForCreateBookmark(answer) {
	if (popupWinId !== 0) {
		switch (answer) {
			case "createYesToAll":
				userAnswerForCreateBookmark = "yesToAll";
			case "createYes":
				var pageURL = popupData[0].pageURL;
				chrome.bookmarks.create({title:pageURL, url:pageURL}, function(result) {
					if (!result) {
						backgroundWin.bannedWatch();
						logWin.log("red", "Error create bookmark");
						userAnswerForCreateBookmark = "noToAll";
						window.setTimeout(function() { popupStep(askForCreateBookmarkId); }, 0);
					} else {
						logWin.log("green", 'Create bookmark at "' + result.url + '"');
						window.setTimeout(function() { popupNext(askForCreateBookmarkId); }, 0);
					}
				});
				break;
			case "createNoToAll":
				userAnswerForCreateBookmark = "noToAll";
			case "createNo":
				var pageURL = popupData[0].pageURL;
				logWin.log("red", 'Fail - Cannot change favicon due to "' + pageURL + '" is not bookmarked');
				window.setTimeout(function() { popupStep(askForCreateBookmarkId); }, 0);
				break;
			case "createCancel":
				chrome.windows.remove(popupWinId);
				break;
		}
	}
	document.getElementById("modalGlass").setAttribute("class", "hide");
	document.getElementById("dialogAskForCreateBookmark").setAttribute("class", "hide");
}
function popupInit() {
	chrome.windows.create({url:initURL, left: 0, top: 0, width: 350, height: 240, focused: true, incognito:false, type:"normal"}, function(win) {
		sessionId ++;
		popupWinId = win.id;
		popupTabId = win.tabs[0].id;
		backgroundWin.popupTabId = popupTabId;
		finishJob = 0;
		totalJob = popupData.length;
		userAnswerForCreateBookmark = null;
		chrome.webRequest.onBeforeRequest.addListener(onBeforeRequest, {urls:["<all_urls>"], windowId: popupWinId}, ["blocking"]);
		chrome.webRequest.onErrorOccurred.addListener(onErrorOccurred, {urls: ["<all_urls>"], windowId: popupWinId});
		chrome.tabs.onUpdated.addListener(onTabUpdated);
		chrome.tabs.onRemoved.addListener(onTabRemoved);
		chrome.tabs.onDetached.addListener(onTabDetached);
		chrome.tabs.onReplaced.addListener(onTabReplaced);
		chrome.windows.onRemoved.addListener(onWindowRemoved);
		window.setTimeout(function() { popupNext(sessionId); }, 0);
	});
}
function popupNext(checkId) {
	if (checkId === sessionId) {
		sessionId ++;
		var id = sessionId;
		var pageURL = popupData[0].pageURL;
		if (!backgroundWin.isUsableURL(pageURL)) {
			logWin.log("red", 'Fail - "' + pageURL + '". "Change favicon", "pin favicon", "reset favicon" and "remove favicon" only support URL that begin with http, https or file');
			(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
		} else {
			(function(id) {
				chrome.bookmarks.search(pageURL, function(results) {
					var pageURL = popupData[0].pageURL;
					var action = popupData[0].action;
					for (var i=0; i < results.length; i++) {
						if (results[i].url === pageURL) {
							if (action === "change") {
								logWin.log("black", 'Change favicon at "' + pageURL + '"');
							} else if (action === "pin") {
								logWin.log("black", 'Pin favicon at "' + pageURL + '"');
							} else if (action === "reset") {
								logWin.log("black", 'Reset favicon at "' + pageURL + '"');
							} else if (action === "remove") {
								logWin.log("black", 'Remove favicon at "' + pageURL + '"');
							}
							(function(id) {
								chrome.extension.isAllowedFileSchemeAccess(function(fileSchemeAccess) {
									var pageURL = popupData[0].pageURL;
									if ((RegExp(/^file:\/\//).test(pageURL)) && (!fileSchemeAccess)) {
										logWin.log("red", 'Fail - Do not have permission to access file URLs at "' + popupData[0].pageURL + '".');
										(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
									} else {
										var action = popupData[0].action;
										timer = window.setTimeout(function() {
											if (popupData[0].cannotConfirm) {
												logWin.log("red", 'Cannot confirm changing of bookmark favicon at "' + popupData[0].pageURL + '".');
											} else {
												logWin.log("red", 'Time error at "' + popupData[0].pageURL + '".');
											}
											sessionId ++;
											var id = sessionId;
											(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
										}, backgroundWin.timeout * 1000);
										if ((action === "reset") && (popupData[0].pageCustomFavicon === backgroundWin.nullPNG)) {
											popupData[0].pageCustomFavicon = backgroundWin.pageDefaultFavicon;
											var link = document.createElement("a");
											link.href = pageURL;
											if (link.protocol === "file:") {
												popupData[0].mostLikelyFaviconURL = "";
												(function(id) {window.setTimeout(function() { popupFindFavicon(id); }, 0);})(id);
												return;
											} else {
												var mostLikelyFaviconURL = link.protocol + "//" + link.host + "/favicon.ico";
												logWin.log("green", 'Loading favicon from "' + mostLikelyFaviconURL + '"');
												try {
													xhr.abort();
												} catch(e) {
												}
												xhr = new XMLHttpRequest();
												xhr.open("GET", mostLikelyFaviconURL, true);
												xhr.responseType = "arraybuffer";
												xhr.addEventListener("abort", function(event) {
													var id = Number(event.target.id);
													if (id === sessionId) {
														logWin.log("red", 'Loading abort at "' + popupData[0].mostLikelyFaviconURL + '".');
														(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
													}
												});
												xhr.addEventListener("error", function(event) {
													var id = Number(event.target.id);
													if (id === sessionId) {
														if (popupData[0].mostLikelyFaviconURL === popupData[0].pageURL) {
															logWin.log("red", 'Loading error at "' + popupData[0].mostLikelyFaviconURL + '".');
															(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
														} else {
															logWin.log("brown", 'Loading error at "' + popupData[0].mostLikelyFaviconURL + '".');
															(function(id) {window.setTimeout(function() { popupFindFavicon(id); }, 0);})(id);
														}
													}
												});
												xhr.addEventListener("load", function(event) {
													var id = Number(event.target.id);
													if (id === sessionId) {
														var arrayBuffer = event.target.response;
														if (!arrayBuffer) {
															if (popupData[0].mostLikelyFaviconURL === popupData[0].pageURL) {
																logWin.log("red", 'Loading error at "' + popupData[0].mostLikelyFaviconURL + '".');
																(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
															} else {
																logWin.log("brown", 'Loading error at "' + popupData[0].mostLikelyFaviconURL + '".');
																(function(id) {window.setTimeout(function() { popupFindFavicon(id); }, 0);})(id);
															}
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
																var id = Number(event.target.id);
																if (id === sessionId) {
																	logWin.log("red", 'Loading abort at "' + popupData[0].mostLikelyFaviconURL + '".');
																	(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
																}
															});
															img.addEventListener("error", function(event) {
																var id = Number(event.target.id);
																if (id === sessionId) {
																	if (popupData[0].mostLikelyFaviconURL === popupData[0].pageURL) {
																		logWin.log("red", 'Loading error at "' + popupData[0].mostLikelyFaviconURL + '".');
																		(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
																	} else {
																		logWin.log("brown", 'Loading error at "' + popupData[0].mostLikelyFaviconURL + '".');
																		(function(id) {window.setTimeout(function() { popupFindFavicon(id); }, 0);})(id);
																	}
																}
															});
															img.addEventListener("load", function(event) {
																var id = Number(event.target.id);
																if (id === sessionId) {
																	popupData[0].pageCustomFavicon = backgroundWin.changeImageToDataURL(event.target);
																	(function(id) {window.setTimeout(function() { popupChangeTab(id); }, 0);})(id);
																}
															});
															img.id = id.toString();
															img.src = imageDataURL;
														}
													}
												});
												popupData[0].mostLikelyFaviconURL = mostLikelyFaviconURL;
												xhr.id = id.toString();
												xhr.send();
												return;
											}
										}
										(function(id) {window.setTimeout(function() { popupChangeTab(id); }, 0);})(id);
									}
								});
							})(id);
							return;
						}
					}
					if (action === "change") {
						askForCreateBookmark(id, pageURL);
					} else {
						logWin.log("red", 'Fail - "' + pageURL + '" is not bookmarked');
						(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
					}
				});
			})(id);
		}
	}
}
function popupFindFavicon(checkId) {
	if (checkId === sessionId) {
		sessionId ++;
		var id = sessionId;
		var pageURL = popupData[0].pageURL;
		logWin.log("green", 'Try to find favicon location from "' + pageURL + '"');
		try {
			xhr.abort();
		} catch(e) {
		}
		xhr = new XMLHttpRequest();
		xhr.open("GET", pageURL, true);
		xhr.responseType = "text";
		xhr.addEventListener("abort", function(event) {
			var id = Number(event.target.id);
			if (id === sessionId) {
				logWin.log("red", 'Loading abort at "' + popupData[0].pageURL + '".');
				(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
			}
		});
		xhr.addEventListener("error", function(event) {
			var id = Number(event.target.id);
			if (id === sessionId) {
				logWin.log("brown", 'Loading error at "' + popupData[0].pageURL + '".');
				(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
			}
		});
		xhr.addEventListener("load", function(event) {
			var id = Number(event.target.id);
			if (id === sessionId) {
				var responseText = event.target.responseText;
				if (responseText) {
					responseText = responseText.replace(/(\n|\r)/gm, "");
					responseText = responseText.replace(/(\t|\s)+/g, " ");
					var baseURL = popupData[0].pageURL;
					var baseTaqs = /<base(\s|\s[^>]+\s)href=("[^"]+"|'[^']+')[^>]*>/i.exec(responseText);
					if (baseTaqs) {
						var baseURLs = /\shref=("[^"]+"|'[^']+')/i.exec(baseTaqs[0]);
						baseURL = baseURLs[0].substr(7, baseURLs[0].length - 8);
					}
					var linkRels = /<link(\s|\s[^>]+\s)rel=("(shortcut\sicon|icon)"|'(shortcut\sicon|icon)')[^>]*>/i.exec(responseText);
					if (linkRels) {
						var relativeFaviconURLs = /\shref=("[^"]+"|'[^']+')/i.exec(linkRels[0]);
						if (relativeFaviconURLs) {
							var relativeFaviconURL = relativeFaviconURLs[0].substr(7, relativeFaviconURLs[0].length - 8);
							var doc = document.implementation.createHTMLDocument();
							var baseTag = doc.createElement("base");
							baseTag.setAttribute("href", baseURL);
							doc.getElementsByTagName("head")[0].appendChild(baseTag);
							var aTag = doc.createElement("a");
							aTag.href = relativeFaviconURL;
							var realFaviconURL = aTag.href;
							doc.getElementsByTagName("head")[0].removeChild(baseTag);
							baseTag = null;
							doc = null;
							aTag = null;
							if ((realFaviconURL === popupData[0].pageURL) || (realFaviconURL === popupData[0].mostLikelyFaviconURL)) {
								logWin.log("red", 'Fail - Cannot find any new location reference to favicon from "' + popupData[0].pageURL + '".');
								(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
							} else {
								popupData[0].realFaviconURL = realFaviconURL;
								(function(id) {window.setTimeout(function() { popupLoadRealFavicon(id); }, 0);})(id);
							}
							return;
						}
					}
				}
				logWin.log("red", 'Fail - Cannot find favicon location from "' + popupData[0].pageURL + '".');
				(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
			}
		});
		xhr.id = id.toString();
		xhr.send();
	}
}
function popupLoadRealFavicon(checkId) {
	if (checkId === sessionId) {
		sessionId ++;
		var id = sessionId;
		var realFaviconURL = popupData[0].realFaviconURL;
		logWin.log("green", 'Loading favicon from "' + realFaviconURL + '"');
		var link = document.createElement("a");
		link.href = realFaviconURL;
		if (link.protocol === "data:") {
			var imageDataURL = backgroundWin.ico16x16Resolution(realFaviconURL);
			var img = new Image();
			img.addEventListener("abort", function(event) {
				var id = Number(event.target.id);
				if (id === sessionId) {
					logWin.log("red", 'Loading abort at "' + popupData[0].realFaviconURL + '".');
					(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
				}
			});
			img.addEventListener("error", function(event) {
				var id = Number(event.target.id);
				if (id === sessionId) {
					logWin.log("red", 'Loading error at "' + popupData[0].realFaviconURL + '".');
					(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
				}
			});
			img.addEventListener("load", function(event) {
				var id = Number(event.target.id);
				if (id === sessionId) {
					popupData[0].pageCustomFavicon = backgroundWin.changeImageToDataURL(event.target);
					(function(id) {window.setTimeout(function() { popupChangeTab(id); }, 0);})(id);
				}
			});
			img.id = id.toString();
			img.src = imageDataURL;
		} else {
			try {
				xhr.abort();
			} catch(e) {
			}
			xhr = new XMLHttpRequest();
			xhr.open("GET", realFaviconURL, true);
			xhr.responseType = "arraybuffer";
			xhr.addEventListener("abort", function(event) {
				var id = Number(event.target.id);
				if (id === sessionId) {
					logWin.log("red", 'Loading abort at "' + popupData[0].realFaviconURL + '".');
					(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
				}
			});
			xhr.addEventListener("error", function(event) {
				var id = Number(event.target.id);
				if (id === sessionId) {
					logWin.log("red", 'Loading error at "' + popupData[0].realFaviconURL + '".');
					(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
				}
			});
			xhr.addEventListener("load", function(event) {
				var id = Number(event.target.id);
				if (id === sessionId) {
					var arrayBuffer = event.target.response;
					if (!arrayBuffer) {
						logWin.log("red", 'Loading error at "' + popupData[0].realFaviconURL + '".');
						(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
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
							var id = Number(event.target.id);
							if (id === sessionId) {
								logWin.log("red", 'Loading abort at "' + popupData[0].realFaviconURL + '".');
								(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
							}
						});
						img.addEventListener("error", function(event) {
							var id = Number(event.target.id);
							if (id === sessionId) {
								logWin.log("red", 'Loading error at "' + popupData[0].realFaviconURL + '".');
								(function(id) {window.setTimeout(function() { popupStep(id); }, 0);})(id);
							}
						});
						img.addEventListener("load", function(event) {
							var id = Number(event.target.id);
							if (id === sessionId) {
								popupData[0].pageCustomFavicon = backgroundWin.changeImageToDataURL(event.target);
								(function(id) {window.setTimeout(function() { popupChangeTab(id); }, 0);})(id);
							}
						});
						img.id = id.toString();
						img.src = imageDataURL;
					}
				}
			});
			xhr.id = id.toString();
			xhr.send();
		}
	}
}
function popupChangeTab(checkId) {
	if (checkId === sessionId) {
		sessionId ++;
		var id = sessionId;
		var pageURL = popupData[0].pageURL;
		var img = new Image();
		img.addEventListener("load", function(event) {
			var id = Number(event.target.id);
			if (id === sessionId) {
				popupData[0].currentFavicon = backgroundWin.changeImageToDataURL(event.target);
				var pageURL = popupData[0].pageURL;
				var pageCustomFavicon = popupData[0].pageCustomFavicon;
				var inner = '<html><head><link rel="icon" href="' + dynamicPNG(pageCustomFavicon) + '" type="image/png" /></head><body><center><h2>Bookmark Favicon Changer</h2><b>Close this window to abort</b>';
				inner += '<br><br><progress value="' + finishJob.toString()+'" max="' + totalJob.toString()+'"></progress>&nbsp;' + Math.floor(finishJob * 100 / totalJob).toString()+'%';
				inner += '</center></body></html>';
				var dynamicHTML = "data:text/html;base64," + window.btoa(inner);
				popupData[0].pageRedirectURL = dynamicHTML;
				popupData[0].id = id;
				chrome.tabs.update(popupTabId, {url: pageURL});
			}
		});
		img.id = id.toString();
		img.src = backgroundWin.getChromeFaviconURL(pageURL);
	}
}
function popupConfirm(checkId) {
	if (checkId === sessionId) {
		sessionId ++;
		var id = sessionId;
		if ((!popupData[0].onlineMode) && (!popupData[0].newFaviconDataURL)) {
			var img = new Image();
			img.addEventListener("load", function(event) {
				var id = Number(event.target.id);
				if (id === sessionId) {
					var redirectFaviconDataURL = backgroundWin.changeImageToDataURL(event.target);
					if ((redirectFaviconDataURL === backgroundWin.pageDefaultFavicon) && (popupData[0].pageCustomFavicon !== backgroundWin.pageDefaultFavicon)) {
						(function(id) {window.setTimeout(function() { popupConfirm(id); }, backgroundWin.popupConfirmInterval);})(id);
					} else {
						popupData[0].newFaviconDataURL = redirectFaviconDataURL;
						(function(id) {window.setTimeout(function() { popupConfirm(id); }, 0);})(id);
					}
				}
			});
			img.id = id.toString();
			img.src = backgroundWin.getChromeFaviconURL(popupData[0].pageRedirectURL);
		} else {
			var pageURL = popupData[0].pageURL;
			var img = new Image();
			img.addEventListener("load", function(event) {
				var id = Number(event.target.id);
				if (id === sessionId) {
					var bookmarkFaviconDataURL = backgroundWin.changeImageToDataURL(event.target);
					var changeDetect = false;
					if (popupData[0].onlineMode) {
						if ((bookmarkFaviconDataURL !== popupData[0].currentFavicon) || (bookmarkFaviconDataURL === popupData[0].pageCustomFavicon)) {
							changeDetect = true;
						}
					} else {
						if (bookmarkFaviconDataURL === popupData[0].newFaviconDataURL) {
							changeDetect = true;
						}
					}
					if (changeDetect) {
						var action = popupData[0].action;
						if (action === "change") {
							var pageOriginalFavicon = popupData[0].pageOriginalFavicon;
							saveFavicon(pageURL, bookmarkFaviconDataURL, pageOriginalFavicon);
							backgroundWin.sendAllContentScriptProperFavicon();
						} else if (action === "pin") {
							var pageOriginalFavicon = popupData[0].pageOriginalFavicon;
							saveFavicon(pageURL, bookmarkFaviconDataURL, pageOriginalFavicon);
							backgroundWin.sendAllContentScriptProperFavicon();
						} else if (action === "reset") {
							deleteFavicon(pageURL);
							backgroundWin.sendAllContentScriptProperFavicon();
						} else if (action === "remove") {
							deleteFavicon(pageURL);
							backgroundWin.sendContentScriptRemoveFavicon(pageURL);
						}
						chrome.runtime.sendMessage({command:"updateList", pageURL:pageURL, pageCustomFavicon:bookmarkFaviconDataURL});
						logWin.log("blue", "Success.");
						popupStep(id);
					} else {
						popupData[0].cannotConfirm = true;
						(function(id) {window.setTimeout(function() { popupConfirm(id); }, backgroundWin.popupConfirmInterval);})(id);
					}
				}
			});
			img.id = id.toString();
			img.src = backgroundWin.getChromeFaviconURL(pageURL);
		}
	}
}
function popupStep(checkId) {
	if (checkId === sessionId) {
		sessionId ++;
		var id = sessionId;
		try {
			clearTimeout(timer);
		} catch(e) {
		}
		try {
			xhr.abort();
		} catch(e) {
		}
		xhr = null;
		finishJob ++;
		if ((popupData[0].action !== "change") && (popupData[0].action !== "pin")) {
			var pageURL = popupData[0].pageURL;
			deleteFavicon(pageURL);
		}
		popupData.shift();
		if (popupData.length === 0) {
			chrome.tabs.update(popupTabId, {url: finishURL});
		} else {
			(function(id) {window.setTimeout(function() { popupNext(id); }, 0);})(id);
		}
	}
}


//================================================
// Import and export function
//================================================
var importActive = false;
var signatureHead = '<html>\n\t<head>\n\t\t<meta charset="utf-8">\n\t\t<title>Custom favicon database</title>\n\t</head>\n\t<body>\n\t\t<h1>Bookmark Favicon Changer<h1>\n\t\t<h2>Custom favicon database</h2>\n\t\t<b>Require minimum Bookmark Favicon Changer version ';
var signatureTableHeader = '</b>\n\t\t<table border="1" cellpadding="5" cellspacing="0">\n\t\t\t<tr>\n\t\t\t\t<td>Custom Favicon</td>\n\t\t\t\t<td>Original Favicon</td>\n\t\t\t\t<td>Bookmark URL</td>\n\t\t\t</tr>\n';
var table1 = '\t\t\t<tr>\n\t\t\t\t<td><center><img src="';
var table2 = '"></img></center></td>\n\t\t\t\t<td><center><img src="';
var table3 = '"></img></center></td>\n\t\t\t\t<td>';
var table4 = '</td>\n\t\t\t</tr>\n';
var tableTail = '\t\t</table>\n';
var tabIconTableHeader = '\n\t\t<br></br>\n\t\t<table border="1" cellpadding="5" cellspacing="0">\n\t\t\t<tr>\n\t\t\t\t<td>Tab Icon</td>\n\t\t\t\t<td>Rule</td>\n\t\t\t</tr>\n';
var tabIconTable1 = '\t\t\t<tr>\n\t\t\t\t<td><center><img src="';
var tabIconTable2 = '"></img></center></td>\n\t\t\t\t<td>';
var tabIconTable3 = '</td>\n\t\t\t</tr>\n';
var tabIconTableTail = '\t\t</table>\n';
var signatureTail = '\t</body>\n</html>';
var dataMerge = [];
var filterDataMerge = [];
var userAnswerForReplaceBookmark = null;
var tabIconRuleMerge = [];
var filterTabIconRuleMerge = [];
var userAnswerForReplaceRule = null;
function exportDatabase() {
	var dataVersion = "2.00";
	var exportText = signatureTableHeader;
	logWin.log("black", "Export Bookmark Favicon Changer database");
	for (var i=0; i < backgroundWin.data.pageURL.length; i++) {
		exportText +=  table1 + backgroundWin.data.pageCustomFavicon[i] + table2 + backgroundWin.data.pageOriginalFavicon[i] + table3 + backgroundWin.data.pageURL[i] + table4;
	}
	exportText += tableTail;
	if (backgroundWin.tabIconRule.length > 0) {
		dataVersion = backgroundWin.thisDataVersion.toFixed(2);
		exportText += tabIconTableHeader;
		for (var i=0; i < backgroundWin.tabIconRule.length; i++) {
			var escapeRule = "";
			var URLRule = backgroundWin.tabIconRule[i].URLRule;
			for (var j=0; j < URLRule.length; j++) {
				escapeRule += "&#" + URLRule.charCodeAt(j).toString() + ";";
			}
			exportText +=  tabIconTable1 + backgroundWin.tabIconRule[i].tabIconURL + tabIconTable2 + escapeRule + tabIconTable3;
		}
		exportText += tabIconTableTail;
	}
	exportText = signatureHead + dataVersion + exportText + signatureTail;
	logWin.log("blue", "Success.");
	saveAs("BookmarkFaviconChangerDatabase.html", exportText, "text/html");
}
function mergeImport(inputHTML) {
	importActive = true;
	var input = inputHTML.replace(/(\t|\n|\r|\s)/gm, "");
	var signatureHeadMod = signatureHead.replace(/(\t|\n|\r|\s)/gm, "");
	var signatureTableHeaderMod = signatureTableHeader.replace(/(\t|\n|\r|\s)/gm, "");
	var table1Mod = table1.replace(/(\t|\n|\r|\s)/gm, "");
	var table2Mod = table2.replace(/(\t|\n|\r|\s)/gm, "");
	var table3Mod = table3.replace(/(\t|\n|\r|\s)/gm, "");
	var table4Mod = table4.replace(/(\t|\n|\r|\s)/gm, "");
	var tableTailMod = tableTail.replace(/(\t|\n|\r|\s)/gm, "");
	var tabIconTableHeaderMod = tabIconTableHeader.replace(/(\t|\n|\r|\s)/gm, "");
	var tabIconTable1Mod = tabIconTable1.replace(/(\t|\n|\r|\s)/gm, "");
	var tabIconTable2Mod = tabIconTable2.replace(/(\t|\n|\r|\s)/gm, "");
	var tabIconTable3Mod = tabIconTable3.replace(/(\t|\n|\r|\s)/gm, "");
	var tabIconTableTailMod = tabIconTableTail.replace(/(\t|\n|\r|\s)/gm, "");
	var signatureTailMod = signatureTail.replace(/(\t|\n|\r|\s)/gm, "");
	if (input.substr(0, signatureHeadMod.length) === signatureHeadMod) {
		input = input.substr(signatureHeadMod.length);
		var inputVersionLength = input.indexOf(signatureTableHeaderMod);
		if (inputVersionLength !== -1) {
			var inputVersion = input.substr(0, inputVersionLength);
			if (!isNaN(inputVersion)) {
				var inputVersionNumber = Number(inputVersion);
				if (inputVersionNumber > backgroundWin.thisVersion) {
					logWin.log("red", "Fail - This database require Bookmark Favicon Changer Version " + inputVersion);
					importActive = false;
					return;
				} else {
					if (inputVersionNumber < backgroundWin.thisDataVersion) {
						if (inputVersionNumber === 2.00) {
							var insertPoint = input.indexOf((tableTailMod + signatureTailMod));
							if (insertPoint === -1) {
								logWin.log("red", "Fail - Invalid file");
								importActive = false;
								return;
							}
							insertPoint += tableTailMod.length;
							input = input.substr(0, insertPoint) + tabIconTableHeaderMod + tabIconTableTailMod + input.substr(insertPoint);
						}
						//if (inputVersionNumber < backgroundWin.thisDataVersion) {}
					}
					input = input.substr(inputVersionLength + signatureTableHeaderMod.length);
					var i = input.indexOf(tableTailMod + tabIconTableHeaderMod);
					if (i !== -1) {
						var dataTable = input.substr(0, i);
						input = input.substr(i + tableTailMod.length + tabIconTableHeaderMod.length);
						dataMerge = [];
						while (dataTable.length !== 0) {
							if (dataTable.substr(0, table1Mod.length) !== table1Mod) {
								logWin.log("red", "Fail - Invalid file");
								importActive = false;
								return;
							}
							dataTable = dataTable.substr(table1Mod.length);
							var i = dataTable.indexOf(table2Mod);
							if (i === -1) {
								logWin.log("red", "Fail - Invalid file");
								importActive = false;
								return;
							}
							var pageCustomFavicon = dataTable.substr(0, i);
							dataTable = dataTable.substr(i + table2Mod.length);
							var i = dataTable.indexOf(table3Mod);
							if (i === -1) {
								logWin.log("red", "Fail - Invalid file");
								importActive = false;
								return;
							}
							var pageOriginalFavicon = dataTable.substr(0, i);
							dataTable = dataTable.substr(i + table3Mod.length);
							var i = dataTable.indexOf(table4Mod);
							if (i === -1) {
								logWin.log("red", "Fail - Invalid file");
								importActive = false;
								return;
							}
							var pageURL = dataTable.substr(0, i);
							dataTable = dataTable.substr(i + table4Mod.length);
							dataMerge.push({pageURL:pageURL, pageCustomFavicon:pageCustomFavicon, pageOriginalFavicon:pageOriginalFavicon});
						}
						var i = input.indexOf(tabIconTableTailMod + signatureTailMod);
						if (i !== -1) {
							var tabIconTable = input.substr(0, i);
							tabIconRuleMerge = [];
							while (tabIconTable.length !== 0) {
								if (tabIconTable.substr(0, tabIconTable1Mod.length) !== tabIconTable1Mod) {
									logWin.log("red", "Fail - Invalid file");
									importActive = false;
									return;
								}
								tabIconTable = tabIconTable.substr(tabIconTable1Mod.length);
								var i = tabIconTable.indexOf(tabIconTable2Mod);
								if (i === -1) {
									logWin.log("red", "Fail - Invalid file");
									importActive = false;
									return;
								}
								var tabIconURL = tabIconTable.substr(0, i);
								tabIconTable = tabIconTable.substr(i + tabIconTable2Mod.length);
								var i = tabIconTable.indexOf(tabIconTable3Mod);
								if (i === -1) {
									logWin.log("red", "Fail - Invalid file");
									importActive = false;
									return;
								}
								var escapeRule = tabIconTable.substr(0, i);
								tabIconTable = tabIconTable.substr(i + tabIconTable3Mod.length);
								if (escapeRule.length === 0) {
									var URLRule = "";
								} else if (escapeRule.length < 4) {
									logWin.log("red", "Fail - Invalid file");
									importActive = false;
									return;
								} else if ((escapeRule.substr(0, 2) !== "&#") || (escapeRule.substr(-1) !== ";")) {
									logWin.log("red", "Fail - Invalid file");
									importActive = false;
									return;
								} else {
									escapeRule = escapeRule.substr(2, escapeRule.length - 3);
									var URLRule = "";
									var charCodeArray = escapeRule.split(";&#");
									try {
										for (var j=0; j < charCodeArray.length; j++) {
											URLRule += String.fromCharCode(Number(charCodeArray[j]));
										}
									} catch(e) {
										logWin.log("red", "Fail - Invalid file");
										importActive = false;
										return;
									}
								}
								var URLRegExp = backgroundWin.ruleToRegExp(URLRule);
								tabIconRuleMerge.push({tabIconURL:tabIconURL, URLRule:URLRule, URLRegExp:URLRegExp});
							}
							if ((dataMerge.length === 0) && (tabIconRuleMerge.length === 0)) {
								logWin.log("red", "Fail - Neither custom favicon nor tab icon is found in imported file");
								importActive = false;
								return;
							} else {
								filterDataMerge = [];
								filterTabIconRuleMerge = [];
								userAnswerForReplaceBookmark = null;
								userAnswerForReplaceRule = null;
								window.setTimeout(function() { addFilterMerge(); }, 0);
								return;
							}
						}
					}
				}
			}
		}
	}
	logWin.log("red", "Fail - Invalid file");
	importActive = false;
}
function addFilterMerge() {
	if (dataMerge.length !== 0) {
		if (!backgroundWin.isUsableURL(dataMerge[0].pageURL)) {
			logWin.log("brown", 'Skip "' + dataMerge[0].pageURL + '". Only support URL that begin with http, https or file.');
			dataMerge.shift();
			window.setTimeout(function() { addFilterMerge(); }, 0);
		} else {
			var i = backgroundWin.data.pageURL.indexOf(dataMerge[0].pageURL);
			if (i === -1) {
				filterDataMerge.push(dataMerge.shift());
				window.setTimeout(function() { addFilterMerge(); }, 0);
			} else {
				if (userAnswerForReplaceBookmark === "yesToAll") {
					answerForReplaceBookmark("replaceYes")
				} else if (userAnswerForReplaceBookmark === "noToAll") {
					answerForReplaceBookmark("replaceNo")
				} else {
					var replaceURLElement = document.getElementById("replaceURL");
					replaceURLElement.removeChild(replaceURLElement.childNodes[0]);
					replaceURLElement.appendChild(document.createTextNode(dataMerge[0].pageURL));
					document.getElementById("databaseCustomFavicon").src = backgroundWin.data.pageCustomFavicon[i];
					document.getElementById("importCustomFavicon").src = dataMerge[0].pageCustomFavicon;
					document.getElementById("modalGlass").setAttribute("class", "modalGlass");
					document.getElementById("dialogAskForReplaceBookmark").setAttribute("class", "dialogAskModal");
				}
			}
		}
	} else {
		if (tabIconRuleMerge.length !== 0) {
			for (var i=0; i < backgroundWin.tabIconRule.length; i++) {
				if (backgroundWin.tabIconRule[i].URLRule === tabIconRuleMerge[0].URLRule) {
					if (userAnswerForReplaceRule === "replaceRuleYesToAll") {
						answerForReplaceRule("replaceRuleYes")
					} else if (userAnswerForReplaceRule === "replaceRuleNoToAll") {
						answerForReplaceRule("replaceRuleNo")
					} else {
						var replaceRuleElement = document.getElementById("replaceRule");
						replaceRuleElement.removeChild(replaceRuleElement.childNodes[0]);
						replaceRuleElement.appendChild(document.createTextNode(tabIconRuleMerge[0].URLRule));
						document.getElementById("databaseTabIcon").src = backgroundWin.tabIconRule[i].tabIconURL;
						document.getElementById("importTabIcon").src = tabIconRuleMerge[0].tabIconURL;
						document.getElementById("modalGlass").setAttribute("class", "modalGlass");
						document.getElementById("dialogAskForReplaceRule").setAttribute("class", "dialogAskModal");
					}
					return;
				}
			}
			filterTabIconRuleMerge.push(tabIconRuleMerge.shift());
			window.setTimeout(function() { addFilterMerge(); }, 0);
		} else {
			if ((filterDataMerge.length === 0) && (filterTabIconRuleMerge.length === 0)) {
				logWin.log("brown", "Neither custom favicon nor tab icon was chosen to import");
			} else {
				var importStatusText = "Importing";
				if (filterDataMerge.length > 0) {
					importStatusText += " " + filterDataMerge.length.toString() + " custom favicon";
				}
				if (filterDataMerge.length > 1) {
					importStatusText += "s";
				}
				if ((filterDataMerge.length !== 0) && (filterTabIconRuleMerge.length !== 0)) {
					importStatusText += " and";
				}
				if (filterTabIconRuleMerge.length > 0) {
					importStatusText += " " + filterTabIconRuleMerge.length.toString() + " tab icon";
				}
				if (filterTabIconRuleMerge.length > 1) {
					importStatusText += "s";
				}
				logWin.log("blue", importStatusText);
				while (filterDataMerge.length !== 0) {
					changeFavicon(filterDataMerge[0].pageURL, filterDataMerge[0].pageCustomFavicon, filterDataMerge[0].pageOriginalFavicon);
					filterDataMerge.shift();
				}
				if (filterTabIconRuleMerge.length > 0) {
					var newTabIconRule = backgroundWin.tabIconRule.slice();
					while (filterTabIconRuleMerge.length !== 0) {
						newTabIconRule.push(filterTabIconRuleMerge[0]);
						for (var i=0; i < backgroundWin.tabIconRule.length; i++) {
							if (backgroundWin.tabIconRule[i].URLRule === filterTabIconRuleMerge[0].URLRule) {
								newTabIconRule[i] = filterTabIconRuleMerge[0];
								newTabIconRule.pop();
								break;
							}
						}
						filterTabIconRuleMerge.shift();
					}
					backgroundWin.tabIconRule = newTabIconRule;
					backgroundWin.saveTabIconRule();
					backgroundWin.sendAllContentScriptProperFavicon();
				}
			}
			importActive = false;
		}
	}
}
function answerForReplaceBookmark(answer) {
	switch (answer) {
		case "replaceYesToAll":
			userAnswerForReplaceBookmark = "yesToAll";
		case "replaceYes":
			filterDataMerge.push(dataMerge.shift());
			window.setTimeout(function() { addFilterMerge(); }, 0);
			break;
		case "replaceNoToAll":
			userAnswerForReplaceBookmark = "noToAll";
		case "replaceNo":
			dataMerge.shift();
			window.setTimeout(function() { addFilterMerge(); }, 0);
			break;
		case "replaceCancel":
			dataMerge = [];
			tabIconRuleMerge = [];
			filterDataMerge = [];
			filterTabIconRuleMerge = [];
			window.setTimeout(function() { addFilterMerge(); }, 0);
			break;
	}
	document.getElementById("modalGlass").setAttribute("class", "hide");
	document.getElementById("dialogAskForReplaceBookmark").setAttribute("class", "hide");
}
function answerForReplaceRule(answer) {
	switch (answer) {
		case "replaceRuleYesToAll":
			userAnswerForReplaceRule = "replaceRuleYesToAll";
		case "replaceRuleYes":
			filterTabIconRuleMerge.push(tabIconRuleMerge.shift());
			window.setTimeout(function() { addFilterMerge(); }, 0);
			break;
		case "replaceRuleNoToAll":
			userAnswerForReplaceRule = "replaceRuleNoToAll";
		case "replaceRuleNo":
			tabIconRuleMerge.shift();
			window.setTimeout(function() { addFilterMerge(); }, 0);
			break;
		case "replaceRuleCancel":
			dataMerge = [];
			tabIconRuleMerge = [];
			filterDataMerge = [];
			filterTabIconRuleMerge = [];
			window.setTimeout(function() { addFilterMerge(); }, 0);
			break;
	}
	document.getElementById("modalGlass").setAttribute("class", "hide");
	document.getElementById("dialogAskForReplaceRule").setAttribute("class", "hide");
}


//================================================
// Begin here
//================================================
document.addEventListener("DOMContentLoaded", function() {
	chrome.runtime.getBackgroundPage(function(backgroundPage) {
		backgroundWin = backgroundPage;
		chrome.tabs.getCurrent(function(tab) {
			backgroundWin.optionsTabId = tab.id;
			backgroundWin.popupTabId = popupTabId;
			document.getElementById("bookmarkFaviconCell").addEventListener("click", function(event) {
				document.getElementById("mainIFrame").src = "bookmarkManager.xhtml";
			});
			document.getElementById("shortcutCell").addEventListener("click", function(event) {
				document.getElementById("mainIFrame").src = "shortcut.xhtml";
			});
			document.getElementById("tabIconCell").addEventListener("click", function(event) {
				document.getElementById("mainIFrame").src = "tabIcon.xhtml";
			});
			document.getElementById("advanceSettingsCell").addEventListener("click", function(event) {
				document.getElementById("mainIFrame").src = "advanceSettings.xhtml";
			});
			document.getElementById("moreCell").addEventListener("click", function(event) {
				document.getElementById("mainIFrame").src = "more.xhtml";
			});
			document.getElementById("aboutCell").addEventListener("click", function(event) {
				document.getElementById("mainIFrame").src = "about.xhtml";
			});
			document.getElementById("showAllLog").addEventListener("click", function(event) {
				logWin.show("all");
			});
			document.getElementById("showOnlyError").addEventListener("click", function(event) {
				logWin.show("error");
			});
			document.getElementById("clearLog").addEventListener("click", function(event) {
				logWin.clearLog();
			});
			document.getElementById("modalGlass").addEventListener("click", function(event) {
				event.stopPropagation();
			});
			document.getElementById("createYes").addEventListener("click", function(event) {
				answerForCreateBookmark("createYes");
			});
			document.getElementById("createYesToAll").addEventListener("click", function(event) {
				answerForCreateBookmark("createYesToAll");
			});
			document.getElementById("createNo").addEventListener("click", function(event) {
				answerForCreateBookmark("createNo");
			});
			document.getElementById("createNoToAll").addEventListener("click", function(event) {
				answerForCreateBookmark("createNoToAll");
			});
			document.getElementById("createCancel").addEventListener("click", function(event) {
				answerForCreateBookmark("createCancel");
			});
			document.getElementById("replaceYes").addEventListener("click", function(event) {
				answerForReplaceBookmark("replaceYes");
			});
			document.getElementById("replaceYesToAll").addEventListener("click", function(event) {
				answerForReplaceBookmark("replaceYesToAll");
			});
			document.getElementById("replaceNo").addEventListener("click", function(event) {
				answerForReplaceBookmark("replaceNo");
			});
			document.getElementById("replaceNoToAll").addEventListener("click", function(event) {
				answerForReplaceBookmark("replaceNoToAll");
			});
			document.getElementById("replaceCancel").addEventListener("click", function(event) {
				answerForReplaceBookmark("replaceCancel");
			});
			document.getElementById("replaceRuleYes").addEventListener("click", function(event) {
				answerForReplaceRule("replaceRuleYes");
			});
			document.getElementById("replaceRuleYesToAll").addEventListener("click", function(event) {
				answerForReplaceRule("replaceRuleYesToAll");
			});
			document.getElementById("replaceRuleNo").addEventListener("click", function(event) {
				answerForReplaceRule("replaceRuleNo");
			});
			document.getElementById("replaceRuleNoToAll").addEventListener("click", function(event) {
				answerForReplaceRule("replaceRuleNoToAll");
			});
			document.getElementById("replaceRuleCancel").addEventListener("click", function(event) {
				answerForReplaceRule("replaceRuleCancel");
			});
			window.addEventListener("beforeunload", function(event) {
				if (popupWinId !== 0) {
					chrome.windows.remove(popupWinId);
				}
				backgroundWin.optionsUnload();
			});
			window.addEventListener("resize", function(event) {
				resizeIFrame();
			});
			window.addEventListener("keyup", function(event) {
				if (event.keyCode === 46) {
					try {
						window.top.bookmarkWin.deleteBookmark();
					} catch(e) {
					}
				}
			});
			chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
				if (request.command === "justBanned") {
					window.setTimeout(function() { bannedAlert(); }, 0);
				}
			});
			var search = window.location.search;
			if (search === "?bookmarkFavicon") {
				var targetCell = document.getElementById("bookmarkFaviconCell");
				var hash = window.location.hash;
				if (hash.length > 1) {
					targetFolder = hash.substr(1);
				} else {
					targetFolder = backgroundWin.bookmarkBarId;
				}
				targetRule = 0;
			} else if (search === "?tabIcon") {
				var targetCell = document.getElementById("tabIconCell");
				var hash = window.location.hash;
				if (hash.length > 1) {
					try {
						targetRule = Number(hash.substr(1))+1;
					} catch(e) {
						targetRule = 0;
					}
				} else {
					targetRule = 0;
				}
				targetFolder = backgroundWin.bookmarkBarId;
			} else if (search === "?advanceSettings") {
				var targetCell = document.getElementById("advanceSettingsCell");
				targetFolder = backgroundWin.bookmarkBarId;
				targetRule = 0;
			} else {
				var targetCell = document.getElementById("bookmarkFaviconCell");
				targetFolder = backgroundWin.bookmarkBarId;
				targetRule = 0;
			}
			resizeIFrame();
			if (backgroundWin.banned) {
				window.setTimeout(function() { bannedAlert(); }, 0);
			}
			targetCell.click();
		});
	});
});
