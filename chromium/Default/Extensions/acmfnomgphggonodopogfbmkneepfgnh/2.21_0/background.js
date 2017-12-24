//================================================================
// Bookmark Favicon Changer by Sonthakit Leelahanon.
// Copyright 2014 Sonthakit Leelahanon. All rights reserved.
//================================================================
"use strict";


// Constant
var thisVersion = 2.21;
var thisDataVersion = 2.13;
var separator1 = " ";
var separator2 = "  ";
var popupConfirmInterval = 100;
var purgeDelay = 3000;
var sizeDIPBegin = 65;
var sizeDIPEnd = 0x7FFFFFFF;
var webkitImageSmoothingEnabled = true;
var noneIconTitle = "Neither custom favicon nor tab icon match for this page";
var tabIconTitle = "This page use custom tab icon";
var customFaviconTitle = "This page use custom favicon";
var nullPNG = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAHklEQVQ4T2NkoBAwUqifYdQAhtEwACai0XQwGMIAACaYABGnE9aRAAAAIXRFWHRCb29rbWFyayBGYXZpY29uIENoYW5nZXIAMDAwMDAwMDCGY5+4AAAAAElFTkSuQmCC";


// Global
var dataVerify = false;
var bookmarkBarNameVerify = false;
var pageDefaultFavicon = null;
var data = {pageURL:[], pageCustomFavicon:[], pageOriginalFavicon:[]};
var redirectData = {fromURL:[], toURL:[]};
var tabIconRule = [];
var timeout = 20;
var autoHideBookmarkBarName = false;
var showPageAction = 2;
var pageActionToOptions = false;
var popupTabId = 0;
var optionsTabId = 0;
var sizeDIP = sizeDIPBegin;
var bookmarkBarName = {id:[], title:[]};
var job = [];
var bookmarkRootId = null;
var bookmarkBarId = null;
var bookmarkOtherId = null;
var banned = false;


//================================================
// General Function
//================================================
function isUsableURL(pageURL) {
	return RegExp(/^(https?|file):\/\//).test(pageURL);
}
function bannedWatch() {
	if (!banned) {
		try {
			var lastError = chrome.runtime.lastError.message;
			if (lastError) {
				if ((lastError.indexOf("MAX_SUSTAINED_WRITE_OPERATIONS_PER_MINUTE") !== -1) || (lastError.indexOf("MAX_WRITE_OPERATIONS_PER_HOUR") !== -1)) {
					banned = true;
					chrome.runtime.sendMessage({command:"justBanned"});
				}
			}
		} catch(e) {
		}
	}
}
function changeImageToDataURL(img) {
	var imgWidth = img.width;
	var imgHeight = img.height;
	if ((imgWidth > 16) || (imgHeight > 16)) {
		var resizeRatio = 16 / (Math.max(imgWidth, imgHeight));
		imgWidth = Math.max(1, Math.round(imgWidth * resizeRatio));
		imgHeight = Math.max(1, Math.round(imgHeight * resizeRatio));
	}
	var canvas = document.createElement("canvas");
	canvas.setAttribute("width", 16);
	canvas.setAttribute("height", 16);
	var ctx = canvas.getContext("2d");
	ctx.clearRect (0, 0, 16, 16);
	ctx.webkitImageSmoothingEnabled = webkitImageSmoothingEnabled;
	ctx.drawImage(img, Math.ceil((16-imgWidth)/2), Math.ceil((16-imgHeight)/2), imgWidth, imgHeight);
	var imgDataURL = canvas.toDataURL("image/png", "");
	ctx = null;
	canvas = null;
	return imgDataURL;
}


//================================================
// Page Action
//================================================
function saveShowPageAction() {
	try {localStorage.showPageAction = showPageAction.toString();} catch(e) {alert(e);}
}
function loadShowPageAction() {
	showPageAction = Number(localStorage.showPageAction);
}
function savePageActionToOptions() {
	try {localStorage.pageActionToOptions = Number(pageActionToOptions).toString();} catch(e) {alert(e);}
}
function loadPageActionToOptions() {
	pageActionToOptions = (localStorage.pageActionToOptions === "1");
}
function resetAllTabPageAction() {
	chrome.extension.isAllowedIncognitoAccess(function(incognitoAccess) {
		(function(incognitoAccess) {
			chrome.extension.isAllowedFileSchemeAccess(function(fileSchemeAccess) {
				(function(incognitoAccess, fileSchemeAccess) {
					chrome.tabs.query({windowType: "normal"}, function(tabs) {
						if (tabs) {
							for (var i=0; i < tabs.length; i++) {
								if ((incognitoAccess) || (!tabs[i].incognito)) {
									if (isUsableURL(tabs[i].url)) {
										if ((fileSchemeAccess) || (!RegExp(/^file:\/\//).test(tabs[i].url))) {
											var tabId = tabs[i].id;
											if (showPageAction === 0) {
												try {
													chrome.pageAction.hide(tabId);
												} catch(e) {
												}
											} else {
												var tabIncognito = tabs[i].incognito;
												(function(tabId, tabIncognito) {
													chrome.pageAction.getTitle({tabId:tabId}, function(result) {
														if (result) {
															try {
																if (result === noneIconTitle) {
																	if (showPageAction === 1) {
																		chrome.pageAction.hide(tabId);
																	} else {
																		chrome.pageAction.show(tabId);
																		if ((pageActionToOptions) || (tabIncognito)) {
																			chrome.pageAction.setPopup({tabId:tabId, popup:""});
																		} else {
																			chrome.pageAction.setPopup({tabId:tabId, popup:"popup.xhtml?" + tabId.toString()});
																		}
																	}
																} else {
																	chrome.pageAction.show(tabId);
																	if ((pageActionToOptions) || (tabIncognito)) {
																		chrome.pageAction.setPopup({tabId:tabId, popup:""});
																	} else {
																		chrome.pageAction.setPopup({tabId:tabId, popup:"popup.xhtml?" + tabId.toString()});
																	}
																}
															} catch(e) {
															}
														}
													});
												})(tabId, tabIncognito);
											}
										}
									}
								}
							}
						}
					});
				})(incognitoAccess, fileSchemeAccess);
			});
		})(incognitoAccess);
	});
}
function setTabPageAction(tabId, tabIncognito, match) {
	if (match === "none") {
		chrome.pageAction.setIcon({tabId:tabId, path:{19:"icon19x.png", 38:"icon38x.png"}});
		chrome.pageAction.setTitle({tabId:tabId, title:noneIconTitle});
		if (showPageAction === 2) {
			chrome.pageAction.show(tabId);
			if ((pageActionToOptions) || (tabIncognito)) {
				chrome.pageAction.setPopup({tabId:tabId, popup:""});
			} else {
				chrome.pageAction.setPopup({tabId:tabId, popup:"popup.xhtml?" + tabId.toString()});
			}
		} else {
			chrome.pageAction.hide(tabId);
		}
	} else {
		chrome.pageAction.setIcon({tabId:tabId, path:{19:"icon19.png", 38:"icon38.png"}});
		if (match === "rule") {
			chrome.pageAction.setTitle({tabId:tabId, title:tabIconTitle});
		} else {
			chrome.pageAction.setTitle({tabId:tabId, title:customFaviconTitle});
		}
		if (showPageAction === 0) {
			chrome.pageAction.hide(tabId);
		} else {
			chrome.pageAction.show(tabId);
			if ((pageActionToOptions) || (tabIncognito)) {
				chrome.pageAction.setPopup({tabId:tabId, popup:""});
			} else {
				chrome.pageAction.setPopup({tabId:tabId, popup:"popup.xhtml?" + tabId.toString()});
			}
		}
	}
}
function pageActionClick(pageURL) {
	if (optionsTabId !== 0) {
		chrome.tabs.update(optionsTabId, {active:true}, function(tab) {
			if (tab) {
				chrome.windows.update(tab.windowId, {focused:true});
			} else {
				window.open("options.xhtml");
			}
		});
		return;
	}
	if (pageURL === "AdvanceSettings") {
		window.open("options.xhtml?advanceSettings");
	} else {
		(function(pageURL) {
			chrome.bookmarks.search(pageURL, function(results) {
				if (results) {
					for (var i=0; i < results.length; i++) {
						if (results[i].url === pageURL) {
							window.open("options.xhtml?bookmarkFavicon#" + results[i].id);
							return;
						}
					}
				}
				var i = redirectData.toURL.indexOf(pageURL);
				if (i !== -1) {
					var fromURL = redirectData.fromURL[i];
					(function(pageURL, fromURL) {
						chrome.bookmarks.search(fromURL, function(results) {
							if (results) {
								for (var j=0; j < results.length; j++) {
									if (results[j].url === fromURL) {
										window.open("options.xhtml?bookmarkFavicon#" + results[j].id);
										return;
									}
								}
							}
							var modifiedURL = escape(unescape(pageURL));
							for (var i=0; i < tabIconRule.length; i++) {
								if ((new RegExp(tabIconRule[i].URLRegExp, "")).test(modifiedURL)) {
									window.open("options.xhtml?tabIcon#" + i.toString());
									return;
								}
							}
							window.open("options.xhtml");
						});
					})(pageURL, fromURL);
					return;
				}
				var modifiedURL = escape(unescape(pageURL));
				for (var i=0; i < tabIconRule.length; i++) {
					if ((new RegExp(tabIconRule[i].URLRegExp, "")).test(modifiedURL)) {
						window.open("options.xhtml?tabIcon#" + i.toString());
						return;
					}
				}
				window.open("options.xhtml");
			});
		})(pageURL);
	}
}
function addListenerPageAction() {
	chrome.pageAction.onClicked.addListener(function(tab) {
		pageActionClick(tab.url);
	});
}


//================================================
// Content Script
//================================================
function sendContentScriptProperFavicon(tabId, tabIncognito, pageURL, sendRollBack) {
	var i = data.pageURL.indexOf(pageURL);
	if (i !== -1) {
		var pageCustomFavicon = data.pageCustomFavicon[i];
		chrome.tabs.sendMessage(tabId, {command:"setPageFavicon", tabURL:pageURL, pageCustomFavicon:pageCustomFavicon});
		setTabPageAction(tabId, tabIncognito, "data");
		return;
	} else {
		var j = redirectData.toURL.indexOf(pageURL);
		if (j !== -1) {
			var k = data.pageURL.indexOf(redirectData.fromURL[j]);
			if (k !== -1) {
				var pageCustomFavicon = data.pageCustomFavicon[k];
				chrome.tabs.sendMessage(tabId, {command:"setPageFavicon", tabURL:pageURL, pageCustomFavicon:pageCustomFavicon});
				setTabPageAction(tabId, tabIncognito, "redirect");
				return;
			}
		}
		var modifiedURL = escape(unescape(pageURL));
		for (var i=0; i < tabIconRule.length; i++) {
			if ((new RegExp(tabIconRule[i].URLRegExp, "")).test(modifiedURL)) {
				var pageCustomFavicon = tabIconRule[i].tabIconURL;
				chrome.tabs.sendMessage(tabId, {command:"setPageFavicon", tabURL:pageURL, pageCustomFavicon:pageCustomFavicon});
				setTabPageAction(tabId, tabIncognito, "rule");
				return;
			}
		}
		if (sendRollBack) {
			chrome.tabs.sendMessage(tabId, {command:"rollBack", tabURL:pageURL, pageDefaultFavicon:pageDefaultFavicon});
		}
		setTabPageAction(tabId, tabIncognito, "none");
	}
}
function sendAllContentScriptProperFavicon() {
	chrome.extension.isAllowedIncognitoAccess(function(incognitoAccess) {
		(function(incognitoAccess) {
			chrome.extension.isAllowedFileSchemeAccess(function(fileSchemeAccess) {
				(function(incognitoAccess, fileSchemeAccess) {
					chrome.tabs.query({windowType: "normal"}, function(tabs) {
						if (tabs) {
							for (var i=0; i < tabs.length; i++) {
								if ((incognitoAccess) || (!tabs[i].incognito)) {
									if (isUsableURL(tabs[i].url)) {
										if ((fileSchemeAccess) || (!RegExp(/^file:\/\//).test(tabs[i].url))) {
											sendContentScriptProperFavicon(tabs[i].id, tabs[i].incognito, tabs[i].url, true);
										}
									}
								}
							}
						}
					});
				})(incognitoAccess, fileSchemeAccess);
			});
		})(incognitoAccess);
	});
}
function sendContentScriptRemoveFavicon(pageURL) {
	chrome.extension.isAllowedIncognitoAccess(function(incognitoAccess) {
		(function(incognitoAccess, pageURL) {
			chrome.tabs.query({windowType: "normal"}, function(tabs) {
				if (tabs) {
					for (var i=0; i < tabs.length; i++) {
						if ((incognitoAccess) || (!tabs[i].incognito)) {
							if (tabs[i].url === pageURL) {
								chrome.tabs.sendMessage(tabs[i].id, {command:"setPageFavicon", tabURL:pageURL, pageCustomFavicon:pageDefaultFavicon});
								setTabPageAction(tabs[i].id, tabs[i].incognito, "none");
							}
						}
					}
				}
			});
		})(incognitoAccess, pageURL);
	});
}
function addListenerContentScript() {
	chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
		if (request.command === "contentScriptLoaded") {
			var tabId = sender.tab.id;
			if (tabId !== popupTabId) {
				(function(tabId) {
					chrome.tabs.query({windowType: "normal"}, function(tabs) {
						if (tabs) {
							for (var i=0; i < tabs.length; i++) {
								if (tabs[i].id === tabId) {
									sendContentScriptProperFavicon(tabs[i].id, tabs[i].incognito, tabs[i].url, false);
									return;
								}
							}
						}
					});
				})(tabId);
			}
		}
	});
	chrome.tabs.onReplaced.addListener(function(addedTabId, removedTabId) {
		if ((addedTabId !== popupTabId) && (removedTabId !== popupTabId)) {
			chrome.extension.isAllowedIncognitoAccess(function(incognitoAccess) {
				(function(incognitoAccess) {
					chrome.extension.isAllowedFileSchemeAccess(function(fileSchemeAccess) {
						(function(incognitoAccess, fileSchemeAccess) {
							chrome.tabs.get(addedTabId, function(tab) {
								if (tab) {
									if (isUsableURL(tab.url)) {
										if ((!tab.incognito) || (incognitoAccess)) {
											if ((fileSchemeAccess) || (!RegExp(/^file:\/\//).test(tab.url))) {
												sendContentScriptProperFavicon(tab.id, tab.incognito, tab.url, false);
											}
										}
									}
								}
							});
						})(incognitoAccess, fileSchemeAccess);
					});
				})(incognitoAccess);
			});
		}
	});
}


//========================================================================
// Job rescue due to popup closed premature when click input type="file"
//========================================================================
var actionData = {beginTime:0};
var currentId = 0;
function getChromeFaviconURL(pageURL) {
	var chromeFaviconURL = "chrome://favicon/size/" + sizeDIP.toString() + "@1x/" + pageURL;
	sizeDIP ++;
	if (sizeDIP > sizeDIPEnd) {
		sizeDIP = sizeDIPBegin;
	}
	return chromeFaviconURL;
}
function ico16x16Resolution(inputDataURL) {
	var outputDataURL = inputDataURL;
	try {
		var dataURLHeader = inputDataURL.split(",")[0];
		if ((dataURLHeader === "data:image/x-icon;base64") || (dataURLHeader === "data:;base64")) {
			var byteString = atob(inputDataURL.split(",")[1]);
			if (byteString.substr(0, 4) === "\x00\x00\x01\x00") {
				var numberOfImage = byteString.charCodeAt(4) + (byteString.charCodeAt(5) * 256);
				for (var i=0; i < numberOfImage; i++) {
					if ((byteString.charCodeAt(6 + (16 * i)) === 16) && (byteString.charCodeAt(7 + (16 * i)) === 16)) {
						outputDataURL = "data:image/x-icon;base64," + btoa("\x00\x00\x01\x00\x01\x00" + byteString.substr(6 + (16 * i), 16) + byteString.substr(22));
						break;
					}
				}
			}
		}
	} catch(e) {
	}
	return outputDataURL;
}
function addListenerPopupRescue() {
	chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
		if (request.command === "contentScriptNotification") {
			chrome.notifications.create("Bookmark Favicon Changer", {type:"basic", title:"Bookmark Favicon Changer", message:request.message, iconUrl:"icon80.png"}, function(notificationId) {});
		} else if (request.command === "popupRescueChangeFavicon") {
			popupRescueChangeFavicon(sender.tab.id, request.pageURL, request.originURL, request.imageDataURL);
		} else if (request.command === "popupRescueChangeIconEdit") {
			popupRescueChangeIconEdit(request.imageDataURL, request.URLRule);
		} else if (request.command === "popupRescueOKAddRule") {
			popupRescueOKAddRule(request.imageDataURL, request.URLRule);
		}
	});
}
function popupRescueChangeFavicon(tabId, pageURL, originURL, imageDataURL) {
	var elapseTime = (new Date()).getTime() - actionData.beginTime;
	if (elapseTime < (timeout * 1000)) {
		(function(tabId, pageURL, originURL, imageDataURL) {window.setTimeout(function() { popupRescueChangeFavicon(tabId, pageURL, originURL, imageDataURL); }, popupConfirmInterval);})(tabId, pageURL, originURL, imageDataURL);
	} else {
		var beginTime = (new Date()).getTime();
		currentId ++;
		var id = currentId;
		actionData = {id:id, tabId:tabId, pageURL:pageURL, originURL:originURL, beginTime:beginTime};
		var img = new Image();
		img.addEventListener("abort", function(event) {
			if (actionData.id === currentId) {
				chrome.notifications.create("Bookmark Favicon Changer", {type:"basic", title:"Bookmark Favicon Changer", message:"Change Favicon Fail - Image loading aborted.", iconUrl:"icon80.png"}, function(notificationId) {});
				actionData = {beginTime:0};
			}
		});
		img.addEventListener("error", function(event) {
			if (actionData.id === currentId) {
				chrome.notifications.create("Bookmark Favicon Changer", {type:"basic", title:"Bookmark Favicon Changer", message:"Change Favicon Fail - Image error or not support.", iconUrl:"icon80.png"}, function(notificationId) {});
				actionData = {beginTime:0};
			}
		});
		img.addEventListener("load", function(event) {
			if (actionData.id === currentId) {
				var pageCustomFavicon = changeImageToDataURL(event.target);
				actionData.pageCustomFavicon = pageCustomFavicon;
				var i = data.pageURL.indexOf(actionData.originURL);
				if (i !== -1) {
					if (data.pageOriginalFavicon[i] !== nullPNG) {
						actionData.pageOriginalFavicon = data.pageOriginalFavicon[i];
					}
				}
				popupRescueSetTabFavicon();
			}
		});
		img.src = ico16x16Resolution(imageDataURL);
	}
}
function popupRescueSetTabFavicon() {
	if (actionData.id === currentId) {
		var img = new Image();
		img.addEventListener("load", function(event) {
			if (actionData.id === currentId) {
				actionData.currentFavicon = changeImageToDataURL(event.target);
				chrome.tabs.sendMessage(actionData.tabId, {command:"setPageFavicon", tabURL:actionData.pageURL, pageCustomFavicon:actionData.pageCustomFavicon}, function(response) {
					if (response.URLmatch) {
						window.setTimeout(function() { popupRescueConfirmFavicon(); }, popupConfirmInterval);
					} else {
						actionData = {beginTime:0};
					}
				});
			}
		});
		img.src = getChromeFaviconURL(actionData.originURL);
	}
}
function popupRescueConfirmFavicon() {
	if (actionData.id === currentId) {
		var img = new Image();
		img.addEventListener("load", function(event) {
			if (actionData.id === currentId) {
				var bookmarkFaviconDataURL = changeImageToDataURL(event.target);
				if ((bookmarkFaviconDataURL === actionData.currentFavicon) && (bookmarkFaviconDataURL !== actionData.pageCustomFavicon)) {
					var elapseTime = (new Date()).getTime() - actionData.beginTime;
					if (elapseTime < (timeout * 1000)) {
						window.setTimeout(function() { popupRescueConfirmFavicon(); }, popupConfirmInterval);
					} else {
						chrome.notifications.create("Bookmark Favicon Changer", {type:"basic", title:"Bookmark Favicon Changer", message:"Fail - Cannot confirm changing of bookmark favicon. Please use extension options page to set bookmark favicon directly.", iconUrl:"icon80.png"}, function(notificationId) {});
						actionData = {beginTime:0};
					}
				} else {
					if (actionData.pageOriginalFavicon) {
						var pageOriginalFavicon = actionData.pageOriginalFavicon;
					} else {
						var pageOriginalFavicon = actionData.currentFavicon;
					}
					var i = data.pageURL.indexOf(actionData.pageURL);
					if (i === -1) {
						data.pageURL.push(actionData.pageURL);
						data.pageCustomFavicon.push(actionData.pageCustomFavicon);
						data.pageOriginalFavicon.push(pageOriginalFavicon);
					} else {
						data.pageCustomFavicon[i] = actionData.pageCustomFavicon;
						data.pageOriginalFavicon[i] = pageOriginalFavicon;
					}
					saveData();
					sendAllContentScriptProperFavicon();
					chrome.runtime.sendMessage({command:"updateList", pageURL:actionData.originURL, pageCustomFavicon:bookmarkFaviconDataURL});
					actionData = {beginTime:0};
				}
			}
		});
		img.src = getChromeFaviconURL(actionData.originURL);
	}
}
function popupRescueChangeIconEdit(imageDataURL, URLRule) {
	var elapseTime = (new Date()).getTime() - actionData.beginTime;
	if (elapseTime < (timeout * 1000)) {
		(function(imageDataURL, URLRule) {window.setTimeout(function() { popupRescueChangeIconEdit(imageDataURL, URLRule); }, popupConfirmInterval);})(imageDataURL, URLRule);
	} else {
		var beginTime = (new Date()).getTime();
		currentId ++;
		var id = currentId;
		actionData = {id:id, beginTime:beginTime, URLRule:URLRule};
		var img = new Image();
		img.addEventListener("abort", function(event) {
			if (actionData.id === currentId) {
				chrome.notifications.create("Bookmark Favicon Changer", {type:"basic", title:"Bookmark Favicon Changer", message:"Change Tab Icon Fail - Image loading aborted.", iconUrl:"icon80.png"}, function(notificationId) {});
				actionData = {beginTime:0};
			}
		});
		img.addEventListener("error", function(event) {
			if (actionData.id === currentId) {
				chrome.notifications.create("Bookmark Favicon Changer", {type:"basic", title:"Bookmark Favicon Changer", message:"Change Tab Icon Fail - Image error or not support.", iconUrl:"icon80.png"}, function(notificationId) {});
				actionData = {beginTime:0};
			}
		});
		img.addEventListener("load", function(event) {
			if (actionData.id === currentId) {
				var tabIconURL = changeImageToDataURL(event.target);
				for (var i=0; i < tabIconRule.length; i++) {
					if (tabIconRule[i].URLRule === actionData.URLRule) {
						tabIconRule[i].tabIconURL = tabIconURL;
						saveTabIconRule();
						sendAllContentScriptProperFavicon();
						chrome.runtime.sendMessage({command:"updateTabIconRule"});
						actionData = {beginTime:0};
						return;
					}
				}
				chrome.notifications.create("Bookmark Favicon Changer", {type:"basic", title:"Bookmark Favicon Changer", message:"Change Tab Icon Fail - This rule had been deleted.", iconUrl:"icon80.png"}, function(notificationId) {});
				actionData = {beginTime:0};
			}
		});
		img.src = ico16x16Resolution(imageDataURL);
	}
}
function popupRescueOKAddRule(imageDataURL, URLRule) {
	var elapseTime = (new Date()).getTime() - actionData.beginTime;
	if (elapseTime < (timeout * 1000)) {
		(function(imageDataURL, URLRule) {window.setTimeout(function() { popupRescueOKAddRule(imageDataURL, URLRule); }, popupConfirmInterval);})(imageDataURL, URLRule);
	} else {
		var beginTime = (new Date()).getTime();
		currentId ++;
		var id = currentId;
		actionData = {id:id, beginTime:beginTime, URLRule:URLRule};
		var img = new Image();
		img.addEventListener("abort", function(event) {
			if (actionData.id === currentId) {
				chrome.notifications.create("Bookmark Favicon Changer", {type:"basic", title:"Bookmark Favicon Changer", message:"Add Tab Icon Fail - Image loading aborted.", iconUrl:"icon80.png"}, function(notificationId) {});
				actionData = {beginTime:0};
			}
		});
		img.addEventListener("error", function(event) {
			if (actionData.id === currentId) {
				chrome.notifications.create("Bookmark Favicon Changer", {type:"basic", title:"Bookmark Favicon Changer", message:"Add Tab Icon Fail - Image error or not support.", iconUrl:"icon80.png"}, function(notificationId) {});
				actionData = {beginTime:0};
			}
		});
		img.addEventListener("load", function(event) {
			if (actionData.id === currentId) {
				var tabIconURL = changeImageToDataURL(event.target);
				var URLRegExp = ruleToRegExp(actionData.URLRule);
				tabIconRule.push({tabIconURL:tabIconURL, URLRule:actionData.URLRule, URLRegExp:URLRegExp});
				saveTabIconRule();
				sendAllContentScriptProperFavicon();
				chrome.runtime.sendMessage({command:"updateTabIconRule"});
				actionData = {beginTime:0};
			}
		});
		img.src = ico16x16Resolution(imageDataURL);
	}
}


//================================================
// timeout
//================================================
function saveTimeout() {
	try {localStorage.timeout = timeout.toString();} catch(e) {alert(e);}
}
function loadTimeout() {
	timeout = Number(localStorage.timeout);
}


//================================================
// Custom Favicon
//================================================
function saveData() {
	data.pageURL.unshift("pageURL");
	data.pageCustomFavicon.unshift("pageCustomFavicon");
	data.pageOriginalFavicon.unshift("pageOriginalFavicon");
	try {localStorage.data = data.pageURL.join(separator1) + separator2 + data.pageCustomFavicon.join(separator1) + separator2 + data.pageOriginalFavicon.join(separator1);} catch(e) {alert(e);}
	data.pageURL.shift();
	data.pageCustomFavicon.shift();
	data.pageOriginalFavicon.shift();
}
function loadData() {
	var dataText = localStorage.data;
	var splitData = dataText.split(separator2);
	var pageURL = splitData[0].split(separator1);
	var pageCustomFavicon = splitData[1].split(separator1);
	var pageOriginalFavicon = splitData[2].split(separator1);
	pageURL.shift();
	pageCustomFavicon.shift();
	pageOriginalFavicon.shift();
	data = {pageURL:pageURL, pageCustomFavicon:pageCustomFavicon, pageOriginalFavicon:pageOriginalFavicon};
}
function purgeCustomFavicon() {
	if (optionsTabId === 0) {
		if (data.pageURL.length === 0) {
			dataVerify = true;
			return;
		}
		var lastPageURL = false;
		for (var i=0; i < data.pageURL.length; i++) {
			var pageURL = data.pageURL[i];
			if (i === (data.pageURL.length-1)) { lastPageURL = true; }
			(function(pageURL, lastPageURL) {
				chrome.bookmarks.search(pageURL, function(results) {
					if (lastPageURL) {
						dataVerify = true;
					}
					if (results) {
						for (var j=0; j < results.length; j++) {
							if (results[j].url === pageURL) {
								return;
							}
						}
					}
					var k = data.pageURL.indexOf(pageURL);
					if (k !== -1) {
						data.pageURL.splice(k, 1);
						data.pageCustomFavicon.splice(k, 1);
						data.pageOriginalFavicon.splice(k, 1);
						saveData();
						sendAllContentScriptProperFavicon();
					}
				});
			})(pageURL, lastPageURL);
		}
	}
}
function addListenerCustomFavicon() {
	chrome.bookmarks.onChanged.addListener(function(id, changeInfo) {
		if (changeInfo.url) {
			dataVerify = false;
		}
	});
	chrome.bookmarks.onRemoved.addListener(function(id, removeInfo) {
		dataVerify = false;
	});
}


//================================================
// Redirection part
//================================================
function addNewRedirect(fromURL, toURL, tabId) {
	if (fromURL !== toURL) {
		var originURL = fromURL;
		var i = redirectData.toURL.indexOf(toURL);
		if (i !== -1) {
			if (redirectData.fromURL[i] === fromURL) {
				return;
			}
		}
		var j = redirectData.toURL.indexOf(fromURL);
		if (j !== -1) {
			originURL = redirectData.fromURL[j];
			if (i !== -1) {
				if (redirectData.fromURL[i] === originURL) {
					return;
				}
			}
		}
		(function(originURL, toURL, tabId) {
			chrome.bookmarks.search(originURL, function(results) {
				if (results) {
					for (var i=0; i < results.length; i++) {
						if (results[i].url === originURL) {
							redirectData.fromURL.unshift(originURL);
							redirectData.toURL.unshift(toURL);
							chrome.tabs.get(tabId, function(tab) {
								if (tab) {
									sendContentScriptProperFavicon(tab.id, tab.incognito, tab.url, true);
								}
							});
							return;
						}
					}
				}
			});
		})(originURL, toURL, tabId);
	}
}
function detectSilentRedirect(tabId, tabIncognito, tabURL) {
	(function(tabId, tabIncognito, tabURL) {
		chrome.tabs.sendMessage(tabId, {command:"getOriginal"}, function(response) {
			if (response) {
				if (response.currentLocationHref === tabURL) {
					if (response.originalLocationHref !== tabURL) {
						addNewRedirect(response.originalLocationHref, tabURL);
					}
				}
			}
		});
	})(tabId, tabIncognito, tabURL);
}
function addListenerRedirect() {
	chrome.runtime.onMessage.addListener(function(request, sender, sendResponse) {
		if (request.command === "RefreshMetaTaq") {
			if (sender.tab.id !== popupTabId) {
				addNewRedirect(request.fromURL, request.toURL);
			}
		}
	});
	chrome.webRequest.onBeforeRedirect.addListener(function(details) {
		if (details.tabId !== popupTabId) {
			addNewRedirect(details.url, details.redirectUrl);
		}
	}, {urls:["http://*/*", "https://*/*", "file://*"], types:["main_frame"]});
	chrome.webRequest.onResponseStarted.addListener(function(details) {
		if (details.tabId !== popupTabId) {
			var responseHeaders = details.responseHeaders;
			if (responseHeaders) {
				for (var i=0; i < responseHeaders.length; i++) {
					if (responseHeaders[i].name.toLowerCase() === "refresh") {
						var toURL = responseHeaders[i].value;
						if (RegExp(/^\d+;\s*url=/i).test(toURL)) {
							toURL = toURL.replace(/^\d+;\s*url=/i, "");
							addNewRedirect(details.url, toURL);
						}
					}
				}
			}
		}
	}, {urls:["http://*/*", "https://*/*", "file://*"], types:["main_frame"]}, ["responseHeaders"]);
	chrome.tabs.onUpdated.addListener(function(tabId, changeInfo, tab) {
		if (tabId !== popupTabId) {
			if (changeInfo.status === "complete") {
				if (isUsableURL(tab.url)) {
					(function(tab) {
						chrome.extension.isAllowedIncognitoAccess(function(incognitoAccess) {
							if ((!tab.incognito) || (incognitoAccess)) {
								if (!RegExp(/^file:\/\//).test(tab.url)) {
									detectSilentRedirect(tab.id, tab.incognito, tab.url);
								} else {
									(function(tab) {
										chrome.extension.isAllowedFileSchemeAccess(function(fileSchemeAccess) {
											if (fileSchemeAccess) {
												detectSilentRedirect(tab.id, tab.incognito, tab.url);
											}
										});
									})(tab);
								}
							}
						});
					})(tab);
				}
			}
		}
	});
}


//================================================
// Bookmark Bar Name
//================================================
function saveAutoHideBookmarkBarName() {
	try {localStorage.autoHideBookmarkBarName = Number(autoHideBookmarkBarName).toString();} catch(e) {alert(e);}
}
function loadAutoHideBookmarkBarName() {
	autoHideBookmarkBarName = (localStorage.autoHideBookmarkBarName === "1");
}
function saveBookmarkBarName() {
	bookmarkBarName.id.unshift("id");
	bookmarkBarName.title.unshift("title");
	try {localStorage.bookmarkBarName = bookmarkBarName.id.join(separator1) + separator2 + bookmarkBarName.title.join(separator1);} catch(e) {alert(e);}
	bookmarkBarName.id.shift();
	bookmarkBarName.title.shift();
}
function loadBookmarkBarName() {
	var bookmarkBarNameText = localStorage.bookmarkBarName;
	var splitBookmarkBarName = bookmarkBarNameText.split(separator2);
	var id = splitBookmarkBarName[0].split(separator1);
	var title = splitBookmarkBarName[1].split(separator1);
	id.shift();
	title.shift();
	bookmarkBarName = {id:id, title:title};
}
function hideAllBookmarkBarName() {
	job.push({command:"hideAllBookmarkBarName"});
	if (job.length === 1) {
		window.setTimeout(function() { doJob(); }, 0);
	}
}
function unHideAllBookmarkBarName() {
	job.push({command:"unHideAllBookmarkBarName"});
	if (job.length === 1) {
		window.setTimeout(function() { doJob(); }, 0);
	}
}
function checkAndDoBookmarkBarName(id, unHide) {
	job.push({command:"checkAndDoBookmarkBarName", id:id, unHide:unHide});
	if (job.length === 1) {
		window.setTimeout(function() { doJob(); }, 0);
	}
}
function purgeBookmarkBarName() {
	if (optionsTabId === 0) {
		chrome.bookmarks.getChildren(bookmarkBarId, function(results) {
			var newBookmarkBarName = {id:[], title:[]};
			if (results) {
				for (var i=0; i < results.length; i++) {
					var j = bookmarkBarName.id.indexOf(results[i].id);
					if (j !== -1) {
						newBookmarkBarName.id.push(bookmarkBarName.id[j]);
						newBookmarkBarName.title.push(bookmarkBarName.title[j]);
					}
				}
			}
			if (bookmarkBarName !== newBookmarkBarName) {
				bookmarkBarName = newBookmarkBarName;
				saveBookmarkBarName();
			}
			bookmarkBarNameVerify = true;
		});
	}
}
function doJob() {
	if (job.length === 0) {return;}
	switch (job[0].command) {
		case "hideAllBookmarkBarName":
			chrome.bookmarks.getChildren(bookmarkBarId, function(results) {
				job.shift();
				for (var i=(results.length-1); i >=0; i--) {
					var title = results[i].title;
					if ((title !== null) && (title !== "")) {
						job.unshift({command:"hideBookmarkBarName", id:results[i].id, title:title});
					}
				}
				doJob();
			});
			break;
		case "unHideAllBookmarkBarName":
			chrome.bookmarks.getChildren(bookmarkBarId, function(results) {
				job.shift();
				for (var i=(results.length-1); i >=0; i--) {
					var j = bookmarkBarName.id.indexOf(results[i].id);
					if (j !== -1) {
						job.unshift({command:"unHideBookmarkBarName", id:bookmarkBarName.id[j], title:bookmarkBarName.title[j]});
					}
				}
				doJob();
			});
			break;
		case "hideBookmarkBarName":
			chrome.bookmarks.update(job[0].id, {title:""}, function(result) {
				if (!result) {
					bannedWatch();
				} else {
					var title = window.btoa(unescape(encodeURIComponent(job[0].title)));
					var i = bookmarkBarName.id.indexOf(job[0].id);
					if (i === -1) {
						bookmarkBarName.id.push(job[0].id);
						bookmarkBarName.title.push(title);
					} else {
						bookmarkBarName.title[i] = title;
					}
					saveBookmarkBarName();
				}
				job.shift();
				doJob();
			});
			break;
		case "unHideBookmarkBarName":
			var title = decodeURIComponent(escape(window.atob(job[0].title)));
			chrome.bookmarks.update(job[0].id, {title:title}, function(result) {
				if (!result) {
					bannedWatch();
				} else {
					var i = bookmarkBarName.id.indexOf(job[0].id);
					if (i !== -1) {
						bookmarkBarName.id.splice(i, 1);
						bookmarkBarName.title.splice(i, 1);
					}
					saveBookmarkBarName();
				}
				job.shift();
				doJob();
			});
			break;
		case "checkAndDoBookmarkBarName":
			chrome.bookmarks.get(job[0].id, function(results) {
				var unHide = job[0].unHide;
				job.shift();
				if (results) {
					if (results[0].parentId === bookmarkBarId) {
						var title = results[0].title;
						if ((title !== null) && (title !== "")) {
							job.unshift({command:"hideBookmarkBarName", id:results[0].id, title:title});
						}
					} else {
						if (unHide) {
							var i = bookmarkBarName.id.indexOf(results[0].id);
							if (i !== -1) {
								job.unshift({command:"unHideBookmarkBarName", id:bookmarkBarName.id[i], title:bookmarkBarName.title[i]});
							}
						}
					}
				}
				doJob();
			});
			break;
		default:
	}
}
function addListenerBookmarkBarName() {
	chrome.bookmarks.onCreated.addListener(function(id, bookmark) {
		if (autoHideBookmarkBarName) {
			if (bookmark.parentId === bookmarkBarId) {
				if ((bookmark.title !== null) && (bookmark.title !== "")) {
					checkAndDoBookmarkBarName(id, false);
				}
			}
		}
	});
	chrome.bookmarks.onMoved.addListener(function(id, moveInfo) {
		if (autoHideBookmarkBarName) {
			if ((moveInfo.parentId === bookmarkBarId) || (moveInfo.oldParentId === bookmarkBarId)) {
				checkAndDoBookmarkBarName(id, true);
			}
		}
	});
	chrome.bookmarks.onChanged.addListener(function(id, changeInfo) {
		if (autoHideBookmarkBarName) {
			if (changeInfo.title) {
				if (changeInfo.title !== "") {
					checkAndDoBookmarkBarName(id, false);
				}
			}
		}
	});
	chrome.bookmarks.onRemoved.addListener(function(id, removeInfo) {
		bookmarkBarNameVerify = false;
	});
}


//================================================
// Tab icon rule
//================================================
function saveTabIconRule() {
	var dataText = "tabIconURL" + separator1 + "URLRule";
	for (var i=0; i < tabIconRule.length; i++) {
		dataText += separator2 + tabIconRule[i].tabIconURL + separator1 + window.btoa(unescape(encodeURIComponent(tabIconRule[i].URLRule)));
	}
	try {localStorage.tabIconRule = dataText;} catch(e) {alert(e);}
}
function loadTabIconRule() {
	var dataText = localStorage.tabIconRule;
	var splitDataText = dataText.split(separator2);
	splitDataText.shift();
	var newTabIconRule = [];
	for (var i=0; i < splitDataText.length; i++) {
		var splitSplitDataText = splitDataText[i].split(separator1);
		var URLRule = decodeURIComponent(escape(window.atob(splitSplitDataText[1])));
		var URLRegExp = ruleToRegExp(URLRule);
		newTabIconRule.push({tabIconURL:splitSplitDataText[0], URLRule:URLRule, URLRegExp:URLRegExp});
	}
	tabIconRule = newTabIconRule;
}
function ruleToRegExp(rule) {
	var regExpText = "";
	var modifiedURL = escape(unescape(rule));
	for (var i=0; i < modifiedURL.length; i++) {
		var cha = modifiedURL.substr(i, 1);
		if (cha === "*") {
			if (i === (modifiedURL.length - 1)) {
				regExpText += ".*";
			} else {
				regExpText += "[^\/]*";
			}
		} else if (RegExp(/^([0-9]|[A-Z]|[a-z]|%)/).test(cha)) {
			regExpText += cha;
		} else {
			regExpText += "\\" + cha;
		}
	}
	regExpText += "$";
	return regExpText;
}


//================================================
// Maintainance
//================================================
function optionsUnload() {
	optionsTabId = 0;
	window.setTimeout(function() { purgeCustomFavicon(); }, 0);
	window.setTimeout(function() { purgeBookmarkBarName(); }, 0);
}
function addListenerMaintainance() {
	chrome.idle.onStateChanged.addListener(function (newState) {
		if (newState === "idle") {
			if (!dataVerify) {
				purgeCustomFavicon();
			}
			if (!bookmarkBarNameVerify) {
				purgeBookmarkBarName();
			}
		}
	});
}


//================================================
// Main
//================================================
function mainThread() {
	var version = localStorage.version;
	if (!version) {
		localStorage.clear();
		try {localStorage.version = thisVersion.toFixed(2);} catch(e) {alert(e);}
		saveTimeout();
		saveAutoHideBookmarkBarName();
		saveBookmarkBarName();
		saveShowPageAction();
		savePageActionToOptions();
		saveTabIconRule();
		saveData();
	} else {
		var prefVersion = Number(version);
		if (prefVersion < thisVersion) {
			try {localStorage.version = thisVersion.toFixed(2);} catch(e) {alert(e);}
			if (prefVersion < 2.13) {
				saveTabIconRule();
			}
			if (prefVersion < 2.15) {
				saveShowPageAction();
				savePageActionToOptions();
			}
		}
		loadTimeout();
		loadAutoHideBookmarkBarName();
		loadBookmarkBarName();
		loadShowPageAction();
		loadPageActionToOptions();
		loadTabIconRule();
		loadData();
	}
	if (localStorage.bookmarkRootId) {
		bookmarkRootId = localStorage.bookmarkRootId;
		bookmarkBarId = localStorage.bookmarkBarId;
		bookmarkOtherId = localStorage.bookmarkOtherId;
		mainThread2();
	} else {
		chrome.bookmarks.getTree(function(results) {
			bookmarkRootId = results[0].id;
			bookmarkBarId = results[0].children[0].id;
			bookmarkOtherId = results[0].children[1].id;
			localStorage.bookmarkRootId = bookmarkRootId;
			localStorage.bookmarkBarId = bookmarkBarId;
			localStorage.bookmarkOtherId = bookmarkOtherId;
			mainThread2();
		});
	}
}
function mainThread2() {
	var img = new Image();
	img.addEventListener("load", function(event) {
		pageDefaultFavicon = changeImageToDataURL(event.target);
		addListenerPageAction();
		addListenerContentScript();
		addListenerPopupRescue();
		addListenerCustomFavicon();
		addListenerRedirect();
		addListenerBookmarkBarName();
		addListenerMaintainance();
		chrome.extension.isAllowedIncognitoAccess(function(incognitoAccess) {
			(function(incognitoAccess) {
				chrome.extension.isAllowedFileSchemeAccess(function(fileSchemeAccess) {
					(function(incognitoAccess, fileSchemeAccess) {
						chrome.tabs.query({windowType: "normal"}, function(tabs) {
							if (tabs) {
								for (var i=0; i < tabs.length; i++) {
									if ((incognitoAccess) || (!tabs[i].incognito)) {
										if (isUsableURL(tabs[i].url)) {
											if ((fileSchemeAccess) || (!RegExp(/^file:\/\//).test(tabs[i].url))) {
												chrome.tabs.executeScript(tabs[i].id, {file:"contentscript.js", runAt:"document_end"});
											}
										}
									}
								}
							}
							if (autoHideBookmarkBarName) {
								hideAllBookmarkBarName();
							}
						});
					})(incognitoAccess, fileSchemeAccess);
				});
			})(incognitoAccess);
		});
	});
	img.src = "chrome://favicon/";
}

//================================================
// Begin here
//================================================
mainThread();
