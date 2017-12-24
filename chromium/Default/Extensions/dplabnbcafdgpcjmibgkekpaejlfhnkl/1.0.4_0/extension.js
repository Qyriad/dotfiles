/******/ (function(modules) { // webpackBootstrap
/******/ 	// The module cache
/******/ 	var installedModules = {};

/******/ 	// The require function
/******/ 	function __webpack_require__(moduleId) {

/******/ 		// Check if module is in cache
/******/ 		if(installedModules[moduleId])
/******/ 			return installedModules[moduleId].exports;

/******/ 		// Create a new module (and put it into the cache)
/******/ 		var module = installedModules[moduleId] = {
/******/ 			exports: {},
/******/ 			id: moduleId,
/******/ 			loaded: false
/******/ 		};

/******/ 		// Execute the module function
/******/ 		modules[moduleId].call(module.exports, module, module.exports, __webpack_require__);

/******/ 		// Flag the module as loaded
/******/ 		module.loaded = true;

/******/ 		// Return the exports of the module
/******/ 		return module.exports;
/******/ 	}


/******/ 	// expose the modules object (__webpack_modules__)
/******/ 	__webpack_require__.m = modules;

/******/ 	// expose the module cache
/******/ 	__webpack_require__.c = installedModules;

/******/ 	// __webpack_public_path__
/******/ 	__webpack_require__.p = "";

/******/ 	// Load entry module and return exports
/******/ 	return __webpack_require__(0);
/******/ })
/************************************************************************/
/******/ ([
/* 0 */
/***/ function(module, exports, __webpack_require__) {

	__webpack_require__(4); // eslint-disable-line import/no-unresolved

	const ExtensionController = __webpack_require__(13); // eslint-disable-line import/no-unresolved

	class RabbitExtension {

		constructor() {
			this._controller = new ExtensionController();
		}

		initialize() {
			chrome.browserAction.onClicked.addListener(() => {
				if (this._controller) {
					this._controller.onClick();
				}
			});

			chrome.runtime.onMessageExternal.addListener((msg, sender) => {
				if (this._controller) {
					this._controller.onMessage(sender.tab.id, msg);
				}
			});

			chrome.runtime.onMessage.addListener((msg, sender) => {
				if (this._controller) {
					this._controller.onMessage(sender.tab.id, msg);
				}
			});

			chrome.runtime.onConnectExternal.addListener(connection => {
				if (this._controller) {
					this._controller.onWebpageConnection(connection);
				}
			});

			window.getController = () => {
				return this._controller;
			};
		}

	}

	const extension = new RabbitExtension();
	extension.initialize();

/***/ },
/* 1 */,
/* 2 */,
/* 3 */,
/* 4 */
/***/ function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag

	// load the styles
	var content = __webpack_require__(5);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(12)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!./../../node_modules/css-loader/index.js!./../../node_modules/less-loader/index.js?root=..!./extensionIcons.less", function() {
				var newContent = require("!!./../../node_modules/css-loader/index.js!./../../node_modules/less-loader/index.js?root=..!./extensionIcons.less");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ },
/* 5 */
/***/ function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(6)();
	// imports


	// module
	exports.push([module.id, ".icon16 {\n  background-image: url(" + __webpack_require__(7) + ");\n}\n.icon19 {\n  background-image: url(" + __webpack_require__(8) + ");\n}\n.icon32 {\n  background-image: url(" + __webpack_require__(9) + ");\n}\n.icon48 {\n  background-image: url(" + __webpack_require__(10) + ");\n}\n.icon128 {\n  background-image: url(" + __webpack_require__(11) + ");\n}\n", ""]);

	// exports


/***/ },
/* 6 */
/***/ function(module, exports) {

	/*
		MIT License http://www.opensource.org/licenses/mit-license.php
		Author Tobias Koppers @sokra
	*/
	// css base code, injected by the css-loader
	module.exports = function() {
		var list = [];

		// return the list of modules as css string
		list.toString = function toString() {
			var result = [];
			for(var i = 0; i < this.length; i++) {
				var item = this[i];
				if(item[2]) {
					result.push("@media " + item[2] + "{" + item[1] + "}");
				} else {
					result.push(item[1]);
				}
			}
			return result.join("");
		};

		// import a list of modules into the list
		list.i = function(modules, mediaQuery) {
			if(typeof modules === "string")
				modules = [[null, modules, ""]];
			var alreadyImportedModules = {};
			for(var i = 0; i < this.length; i++) {
				var id = this[i][0];
				if(typeof id === "number")
					alreadyImportedModules[id] = true;
			}
			for(i = 0; i < modules.length; i++) {
				var item = modules[i];
				// skip already imported module
				// this implementation is not 100% perfect for weird media query combinations
				//  when a module is imported multiple times with different media queries.
				//  I hope this will never occur (Hey this way we have smaller bundles)
				if(typeof item[0] !== "number" || !alreadyImportedModules[item[0]]) {
					if(mediaQuery && !item[2]) {
						item[2] = mediaQuery;
					} else if(mediaQuery) {
						item[2] = "(" + item[2] + ") and (" + mediaQuery + ")";
					}
					list.push(item);
				}
			}
		};
		return list;
	};


/***/ },
/* 7 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/images/rabbit-16px.png";

/***/ },
/* 8 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/images/rabbit-19px.png";

/***/ },
/* 9 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/images/rabbit-32px.png";

/***/ },
/* 10 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/images/rabbit-48px.png";

/***/ },
/* 11 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/images/rabbit-128px.png";

/***/ },
/* 12 */
/***/ function(module, exports, __webpack_require__) {

	/*
		MIT License http://www.opensource.org/licenses/mit-license.php
		Author Tobias Koppers @sokra
	*/
	var stylesInDom = {},
		memoize = function(fn) {
			var memo;
			return function () {
				if (typeof memo === "undefined") memo = fn.apply(this, arguments);
				return memo;
			};
		},
		isOldIE = memoize(function() {
			return /msie [6-9]\b/.test(window.navigator.userAgent.toLowerCase());
		}),
		getHeadElement = memoize(function () {
			return document.head || document.getElementsByTagName("head")[0];
		}),
		singletonElement = null,
		singletonCounter = 0,
		styleElementsInsertedAtTop = [];

	module.exports = function(list, options) {
		if(false) {
			if(typeof document !== "object") throw new Error("The style-loader cannot be used in a non-browser environment");
		}

		options = options || {};
		// Force single-tag solution on IE6-9, which has a hard limit on the # of <style>
		// tags it will allow on a page
		if (typeof options.singleton === "undefined") options.singleton = isOldIE();

		// By default, add <style> tags to the bottom of <head>.
		if (typeof options.insertAt === "undefined") options.insertAt = "bottom";

		var styles = listToStyles(list);
		addStylesToDom(styles, options);

		return function update(newList) {
			var mayRemove = [];
			for(var i = 0; i < styles.length; i++) {
				var item = styles[i];
				var domStyle = stylesInDom[item.id];
				domStyle.refs--;
				mayRemove.push(domStyle);
			}
			if(newList) {
				var newStyles = listToStyles(newList);
				addStylesToDom(newStyles, options);
			}
			for(var i = 0; i < mayRemove.length; i++) {
				var domStyle = mayRemove[i];
				if(domStyle.refs === 0) {
					for(var j = 0; j < domStyle.parts.length; j++)
						domStyle.parts[j]();
					delete stylesInDom[domStyle.id];
				}
			}
		};
	}

	function addStylesToDom(styles, options) {
		for(var i = 0; i < styles.length; i++) {
			var item = styles[i];
			var domStyle = stylesInDom[item.id];
			if(domStyle) {
				domStyle.refs++;
				for(var j = 0; j < domStyle.parts.length; j++) {
					domStyle.parts[j](item.parts[j]);
				}
				for(; j < item.parts.length; j++) {
					domStyle.parts.push(addStyle(item.parts[j], options));
				}
			} else {
				var parts = [];
				for(var j = 0; j < item.parts.length; j++) {
					parts.push(addStyle(item.parts[j], options));
				}
				stylesInDom[item.id] = {id: item.id, refs: 1, parts: parts};
			}
		}
	}

	function listToStyles(list) {
		var styles = [];
		var newStyles = {};
		for(var i = 0; i < list.length; i++) {
			var item = list[i];
			var id = item[0];
			var css = item[1];
			var media = item[2];
			var sourceMap = item[3];
			var part = {css: css, media: media, sourceMap: sourceMap};
			if(!newStyles[id])
				styles.push(newStyles[id] = {id: id, parts: [part]});
			else
				newStyles[id].parts.push(part);
		}
		return styles;
	}

	function insertStyleElement(options, styleElement) {
		var head = getHeadElement();
		var lastStyleElementInsertedAtTop = styleElementsInsertedAtTop[styleElementsInsertedAtTop.length - 1];
		if (options.insertAt === "top") {
			if(!lastStyleElementInsertedAtTop) {
				head.insertBefore(styleElement, head.firstChild);
			} else if(lastStyleElementInsertedAtTop.nextSibling) {
				head.insertBefore(styleElement, lastStyleElementInsertedAtTop.nextSibling);
			} else {
				head.appendChild(styleElement);
			}
			styleElementsInsertedAtTop.push(styleElement);
		} else if (options.insertAt === "bottom") {
			head.appendChild(styleElement);
		} else {
			throw new Error("Invalid value for parameter 'insertAt'. Must be 'top' or 'bottom'.");
		}
	}

	function removeStyleElement(styleElement) {
		styleElement.parentNode.removeChild(styleElement);
		var idx = styleElementsInsertedAtTop.indexOf(styleElement);
		if(idx >= 0) {
			styleElementsInsertedAtTop.splice(idx, 1);
		}
	}

	function createStyleElement(options) {
		var styleElement = document.createElement("style");
		styleElement.type = "text/css";
		insertStyleElement(options, styleElement);
		return styleElement;
	}

	function createLinkElement(options) {
		var linkElement = document.createElement("link");
		linkElement.rel = "stylesheet";
		insertStyleElement(options, linkElement);
		return linkElement;
	}

	function addStyle(obj, options) {
		var styleElement, update, remove;

		if (options.singleton) {
			var styleIndex = singletonCounter++;
			styleElement = singletonElement || (singletonElement = createStyleElement(options));
			update = applyToSingletonTag.bind(null, styleElement, styleIndex, false);
			remove = applyToSingletonTag.bind(null, styleElement, styleIndex, true);
		} else if(obj.sourceMap &&
			typeof URL === "function" &&
			typeof URL.createObjectURL === "function" &&
			typeof URL.revokeObjectURL === "function" &&
			typeof Blob === "function" &&
			typeof btoa === "function") {
			styleElement = createLinkElement(options);
			update = updateLink.bind(null, styleElement);
			remove = function() {
				removeStyleElement(styleElement);
				if(styleElement.href)
					URL.revokeObjectURL(styleElement.href);
			};
		} else {
			styleElement = createStyleElement(options);
			update = applyToTag.bind(null, styleElement);
			remove = function() {
				removeStyleElement(styleElement);
			};
		}

		update(obj);

		return function updateStyle(newObj) {
			if(newObj) {
				if(newObj.css === obj.css && newObj.media === obj.media && newObj.sourceMap === obj.sourceMap)
					return;
				update(obj = newObj);
			} else {
				remove();
			}
		};
	}

	var replaceText = (function () {
		var textStore = [];

		return function (index, replacement) {
			textStore[index] = replacement;
			return textStore.filter(Boolean).join('\n');
		};
	})();

	function applyToSingletonTag(styleElement, index, remove, obj) {
		var css = remove ? "" : obj.css;

		if (styleElement.styleSheet) {
			styleElement.styleSheet.cssText = replaceText(index, css);
		} else {
			var cssNode = document.createTextNode(css);
			var childNodes = styleElement.childNodes;
			if (childNodes[index]) styleElement.removeChild(childNodes[index]);
			if (childNodes.length) {
				styleElement.insertBefore(cssNode, childNodes[index]);
			} else {
				styleElement.appendChild(cssNode);
			}
		}
	}

	function applyToTag(styleElement, obj) {
		var css = obj.css;
		var media = obj.media;

		if(media) {
			styleElement.setAttribute("media", media)
		}

		if(styleElement.styleSheet) {
			styleElement.styleSheet.cssText = css;
		} else {
			while(styleElement.firstChild) {
				styleElement.removeChild(styleElement.firstChild);
			}
			styleElement.appendChild(document.createTextNode(css));
		}
	}

	function updateLink(linkElement, obj) {
		var css = obj.css;
		var sourceMap = obj.sourceMap;

		if(sourceMap) {
			// http://stackoverflow.com/a/26603875
			css += "\n/*# sourceMappingURL=data:application/json;base64," + btoa(unescape(encodeURIComponent(JSON.stringify(sourceMap)))) + " */";
		}

		var blob = new Blob([css], { type: "text/css" });

		var oldSrc = linkElement.href;

		linkElement.href = URL.createObjectURL(blob);

		if(oldSrc)
			URL.revokeObjectURL(oldSrc);
	}


/***/ },
/* 13 */
/***/ function(module, exports, __webpack_require__) {

	const Config = __webpack_require__(14); // eslint-disable-line import/no-unresolved
	const Settings = __webpack_require__(15); // eslint-disable-line import/no-unresolved
	const WebpageConnection = __webpack_require__(16); // eslint-disable-line import/no-unresolved
	const ExtensionMessages = __webpack_require__(17); // eslint-disable-line
	const ExtensionStates = __webpack_require__(20); // eslint-disable-line import/no-unresolved
	const WebrtcSession = __webpack_require__(21); // eslint-disable-line import/no-unresolved
	const AnalyticsEventTypes = __webpack_require__(22); // eslint-disable-line import/no-unresolved

	class ExtensionController {
		constructor() {
			this._tabCaptureTimeout = null;
			this._tabCaptureTimeoutValue = 10000;
			this._extensionReady = false;
			this._config = new Config();
			this._config.loadConfigFile('config.json').then(() => {
				this._settings = new Settings();
				this._settings.loadSettings();

				this._extensionState = ExtensionStates.Idle;
				this._webrtcSessions = new Map();
				this._tabStream = null;
				this._capturedTabId = null;
				this._capturedTabUpdated = null;
				this._screencasterConnection = null;
				this._connections = new Map();
				this._eventHandlers = new Map();
				this._roomRefreshPoll = null;
				this._eventHandlers.set(ExtensionMessages.msgCreateMediaSession, this._onCreateMediaSession.bind(this));
				this._eventHandlers.set(ExtensionMessages.msgMediaSessionOffer, this._onMediaSessionOffer.bind(this));
				this._eventHandlers.set(ExtensionMessages.msgStopScreenCapture, this.stopTabCapture.bind(this));
				this._eventHandlers.set(ExtensionMessages.msgGetOpenedTabs, this._onGetOpenedTabs.bind(this));
				this._eventHandlers.set(ExtensionMessages.msgSetupTabCapture, this._onSetupTabCapture.bind(this));
				this._eventHandlers.set(ExtensionMessages.msgRoomChanged, this._onConnectionRoomChanged.bind(this));
				this._eventHandlers.set(ExtensionMessages.msgRestartWebrtcConnection, this._onRestartWebrtcConnection.bind(this));
				this._eventHandlers.set(ExtensionMessages.msgUpdateExtensionState, this._onUpdateExtensionState.bind(this));
				this._eventHandlers.set(ExtensionMessages.msgScreencastStarted, this._onScreencastStarted.bind(this));

				if (this._config.getEnvironment() !== 'production') {
					chrome.browserAction.setBadgeText({ text: this._config.getEnvironment() });
					chrome.browserAction.setBadgeBackgroundColor({ color: [255, 102, 0, 255] });
				}
				this._extensionReady = true;
				this._anouncePresence();
				this._setupPolling();
			});
		}

		saveSettings(settings) {
			// settings should only be saved when apply is pressed
			// this._settings.saveSettings(settings);
		}

		applySettings(settings) {
			const oldSettings = this.getCurrentSettings();
			this._settings.saveSettings(settings).then(() => {
				if (this._extensionState !== ExtensionStates.Running) {
					return;
				}

				const newSettings = settings;
				const changeBitrate = oldSettings.bitrate !== newSettings.bitrate;
				const replaceStreams = oldSettings.width !== newSettings.width || oldSettings.height !== newSettings.height || oldSettings.fps !== newSettings.fps;

				if (!changeBitrate && !replaceStreams) {
					return;
				}

				if (replaceStreams) {
					// we need to make the tab active first
					chrome.tabs.get(this._capturedTabId, tab => {
						chrome.windows.update(tab.windowId, { focused: true }, () => {
							chrome.tabs.update(this._capturedTabId, { active: true }, () => {
								this.setupTabCapture(0);
							});
						});
					});
					return;
				}

				if (this._webrtcSessions.size > 1) {
					// console.log('Multiple webrtc session. Ignoring bitrate change. This should not happen!!!');
					return;
				} else if (this._webrtcSessions.size === 0) {
					// console.log('No webrtc sessions. Invalid state. This should not happen!!!');
					return;
				}

				const webrtcId = this._webrtcSessions.values().next().value.getWebrtcId();
				this._sendMessage({
					event: ExtensionMessages.msgUpdateConstantBitrate,
					message: {
						constantBitrate: newSettings.bitrate * 1024,
						webrtcId: webrtcId
					}
				});
			});
		}

		getCurrentSettings() {
			return this._settings.getCurrentSettings();
		}

		getCapturedTabID() {
			return this._capturedTabId;
		}

		onWebpageConnection(connection) {
			if (!this._connections) {
				connection.disconnect();
				return;
			}

			const that = this;
			const connectionId = connection.sender.tab.id;

			const webpageConnection = new WebpageConnection(connectionId, connection);
			webpageConnection.addOnMessageListener((eventConnection, event) => {
				that.onMessage(eventConnection, event);
			});

			webpageConnection.addOnDisconnectListener(disconnectConnection => {
				const disconnectConnectionId = disconnectConnection.getConnectionId();
				that._connections.delete(disconnectConnectionId);
				if (that._screencasterConnection === disconnectConnection) {
					that._screencasterConnection = null;
					that.stopTabCapture();
				}
			});

			this._connections.set(connectionId, webpageConnection);
		}

		isTabStreamIdle() {
			return this._extensionState === ExtensionStates.Idle;
		}

		onMessage(connection, msg) {
			// console.log(connection, msg);
			const event = msg.event;
			const eventHandler = event && this._eventHandlers.get(event);
			if (eventHandler) {
				eventHandler(connection, msg.message);
			} else {
				// console.log(`onMessage --- unhandled message: ${JSON.stringify(msg)}`);
			}
		}

		onClick() {
			if (this._extensionReady) {
				chrome.browserAction.setPopup({ popup: 'popup.html' });
			}
		}

		_startCapture() {
			const that = this;

			const currentSettings = this._settings.getCurrentSettings();

			const captureOptions = {
				audio: true,
				video: true,
				videoConstraints: {
					mandatory: {
						minWidth: currentSettings.width,
						minHeight: currentSettings.height,
						maxWidth: currentSettings.width,
						maxHeight: currentSettings.height,
						maxFrameRate: currentSettings.fps
					}
				}
			};

			return new Promise(resolve => {
				chrome.tabCapture.capture(captureOptions, stream => {
					that._setupStreamEvents(stream);
					that._getActiveTab().then(activeTab => {
						that._setCapturedTab(activeTab);
						resolve(stream);
					});
				});
			});
		}

		_getActiveTab() {
			return new Promise(resolve => {
				chrome.tabs.query({
					active: true,
					currentWindow: true
				}, tabs => {
					let activeTab = null;
					if (tabs.length > 0) {
						activeTab = tabs[0];
						if (tabs.length > 1) {
							// console.log('Multiple active tabs????');
						}
					} else {
							// console.log('No active tab????');
						}
					resolve(activeTab);
				});
			});
		}

		_tabCaptureStarted(screencasterConnection, _makeActive) {
			const startScreencast = this._screencasterConnection === null;
			const makeActive = _makeActive !== false;
			this._screencasterConnection = screencasterConnection;
			this._extensionState = ExtensionStates.Running;
			const tabId = this._screencasterConnection.getTabId();
			const currentSettings = this._settings.getCurrentSettings();

			if (makeActive) {
				chrome.tabs.get(tabId, tab => {
					chrome.windows.update(tab.windowId, { focused: true }, () => {
						chrome.tabs.update(tabId, { active: true }, () => {});
					});
				});
			}

			if (startScreencast) {
				this._startTabCaptureTimeout();
				chrome.tabs.get(this._capturedTabId, tab => {
					this._sendMessage({
						event: ExtensionMessages.msgStartScreencast,
						message: {
							url: tab.url,
							title: tab.title
						}
					});
				});
			} else {
				this._sendCreateMediaSession(currentSettings.bitrate);
			}
		}

		stopTabCapture() {

			const webrtcIds = [];
			for (const webrtcSession of this._webrtcSessions.values()) {
				webrtcIds.push(webrtcSession.getWebrtcId());
				webrtcSession.destroy();
			}

			this._sendMessage({
				event: ExtensionMessages.msgStopScreenCapture,
				message: {
					webrtcIds: webrtcIds
				}
			});

			this._setCapturedTab(null);

			if (this._tabStream) {
				const videoTracks = this._tabStream.getVideoTracks();
				if (videoTracks && videoTracks.length > 0) {
					videoTracks[0].onended = null;
					videoTracks[0].stop();
				}

				const audioTracks = this._tabStream.getAudioTracks();
				if (audioTracks && audioTracks.length > 0) {
					audioTracks[0].stop();
				}

				this._tabStream = null;
			}

			this._webrtcSessions.clear();
			this._screencasterConnection = null;
			this._extensionState = ExtensionStates.Idle;

			for (const connection of this._connections.values()) {
				connection.disconnect();
			}

			this._connections.clear();
			this._connections = null;

			// wait for 500ms and reload the extension
			// reloading the extension cleans up the webrtc-internals for the extension
			setTimeout(() => {
				window.location.reload(true);
			}, 500);
		}

		_sendMessage(msg) {
			if (!this._screencasterConnection) {
				// console.log('No _screencasterConnection');
				return;
			}
			this._sendMessageToConnection(this._screencasterConnection, msg);
		}

		_sendMessageToConnection(connection, msg) {
			if (!connection) {
				// console.log('No connection');
				return;
			}
			connection.send(msg);
		}

		_tabsWithURL(url) {
			return new Promise(resolve => {
				chrome.tabs.query({}, tabs => {
					const tabsArr = tabs.filter(value => {
						return value.url === url;
					});

					resolve(tabsArr);
				});
			});
		}

		_onCreateMediaSession(connection, msg) {
			// console.log('_onCreateMediaSession: ' + JSON.stringify(msg));
			const webrtcId = msg.webrtcId;
			if (!webrtcId) {
				// console.log('_onCreateMediaSession: No webrtcId');
				return;
			}

			if (this._webrtcSessions.get(webrtcId)) {
				// console.log('_onCreateMediaSession: already has an webrtcSession');
				return;
			}

			const webrtcSession = new WebrtcSession(webrtcId, msg.iceServers, this._tabStream);
			webrtcSession.onSignalingStateChange = this._onConnectionStateChange.bind(this, webrtcId);
			webrtcSession.onIceConnectionStateChange = this._onConnectionStateChange.bind(this, webrtcId);
			this._webrtcSessions.set(webrtcId, webrtcSession);
		}

		_onConnectionStateChange(webrtcId) {
			const webrtcSession = this._webrtcSessions.get(webrtcId);
			if (!webrtcSession) {
				// console.log('webrtcSession: No webrtc session');
				return;
			}

			const connectionState = webrtcSession.getConnectionState();
			if (connectionState.iceConnectionState === WebrtcSession.IceConnectionStates.Failed) {
				this._onWebrtcConnectionFailed(webrtcId);
			} else {
				this._sendMessage({
					event: ExtensionMessages.msgMediaSessionState,
					message: {
						webrtcId: webrtcId,
						signalingState: connectionState.signalingState,
						iceGatheringState: connectionState.iceGatheringState,
						iceConnectionState: connectionState.iceConnectionState
					}
				});
			}
		}

		_onMediaSessionOffer(connection, msg) {
			const webrtcId = msg.webrtcId;
			if (!webrtcId) {
				// console.log('_onMediaSessionOffer: No webrtcId');
				return;
			}

			const webrtcSession = this._webrtcSessions.get(webrtcId);
			if (!webrtcSession) {
				// console.log('_onMediaSessionOffer: No webrtc session');
				return;
			}

			webrtcSession.setRemoteDescription(msg.sessionDescription).then(() => {
				return webrtcSession.createAswer();
			}).then(answer => {
				return webrtcSession.setLocalDescription(answer);
			}).then(answer => {
				this._sendMessage({
					event: ExtensionMessages.msgMediaSessionAnswer,
					message: {
						webrtcId: webrtcId,
						sessionDescription: answer
					}
				});
			});
		}

		getOpenedTabs() {
			const that = this;
			return new Promise(resolve => {
				if (this._extensionState === ExtensionStates.Disabled) {
					resolve([]);
					return;
				}

				chrome.tabs.query({}, tabs => {
					chrome.tabs.query({ active: true }, activeTabs => {
						const openedTabs = new Array();
						const getOpenedTabsRecursively = _tabIdx => {
							let tabIdx = _tabIdx;
							if (tabIdx === tabs.length) {
								activeTabs.forEach(tab => {
									chrome.tabs.update(tab.id, { active: true });
								});
								resolve(openedTabs);
								return;
							}
							const tab = tabs[tabIdx];
							that._getOpenedTab(tab).then(capturedData => {
								if (capturedData) {
									openedTabs.push(capturedData);
								}
								++tabIdx;
								getOpenedTabsRecursively(tabIdx);
							});
						};
						getOpenedTabsRecursively(0);
					});
				});
			});
		}

		_getOpenedTab(tab) {
			return new Promise(resolve => {
				if (this._extensionState === ExtensionStates.Disabled) {
					resolve({});
					return;
				}

				// const activeTab = tab;
				// const capturedData = {
				// 	id: activeTab.id,
				// 	type: 'local',
				// 	kind: 'video',
				// 	title: activeTab.title,
				// 	subtitle: activeTab.title,
				// 	url: activeTab.url,
				// 	image: {
				// 		url: ''
				// 	},
				// 	promotional: false
				// };
				// resolve(capturedData);

				chrome.tabs.update(tab.id, { active: true }, activeTab => {
					setTimeout(() => {
						chrome.tabs.captureVisibleTab(activeTab.windowId, { format: 'png' }, _imageUrl => {
							let imageUrl = _imageUrl;
							if (chrome.runtime.lastError || !imageUrl) {
								// console.log('Cannot capture tab: ' + JSON.stringify(chrome.runtime.lastError))
								imageUrl = '';
							}
							const capturedData = {
								id: activeTab.id,
								type: 'local',
								kind: 'video',
								title: activeTab.title,
								subtitle: activeTab.title,
								url: activeTab.url,
								image: {
									url: imageUrl
								},
								promotional: false
							};
							resolve(capturedData);
						});
					}, 50);
				});
			});
		}

		_onGetOpenedTabs(connection) {
			return this.getOpenedTabs().then(openedTabs => {
				this._sendMessageToConnection(connection, {
					event: ExtensionMessages.msgGetOpenedTabs,
					message: {
						openedTabs: openedTabs
					}
				});
			});
		}

		_onSetupTabCapture(connection, msg) {
			const tabId = Number(msg.tabId);
			chrome.tabs.get(tabId, tab => {
				chrome.windows.update(tab.windowId, { focused: true });
			});

			chrome.tabs.update(tabId, { active: true }, () => {
				this._screencasterConnection = connection;
				this._extensionState = ExtensionStates.Setup;
				// chrome.browserAction.setPopup({popup: ''});
			});
		}

		_anouncePresence() {
			chrome.tabs.query({}, tabs => {
				for (const tab of tabs) {
					if (tab.url.indexOf('rabb.it') !== -1) {
						try {
							chrome.tabs.executeScript(tab.id, {
								file: 'presence.js'
							});
						} catch (err) {
							// console.debug('could not accounce extension presence on tab', err);
						}
					}
				}
			});
		}

		_getMyRoomUrlFromServer() {
			return new Promise(resolve => {
				if (this._extensionState === ExtensionStates.Disabled) {
					resolve(null);
					return;
				}

				const defaultRoomUrl = this._config.getServerHostUrl() ? `${this._config.getServerHostUrl()}/start` : null;
				const requestUrl = this._config.getServerDataHttp() ? `${this._config.getServerDataHttp()}/extension` : null;
				if (!requestUrl) {
					resolve(defaultRoomUrl);
					return;
				}

				const request = new XMLHttpRequest();
				request.open('POST', requestUrl, true);
				request.setRequestHeader('Content-Type', 'application/json');
				request.onload = () => {
					let roomUrl = defaultRoomUrl;
					if (request.status === 200 && request.response) {
						try {
							const responseData = JSON.parse(request.response);
							roomUrl = responseData.roomUrl;
						} catch (err) {
							// console.log('Error parsing response data!');
						}
					}
					resolve(roomUrl);
				};

				request.onerror = () => {
					resolve(null);
				};

				request.send(JSON.stringify({ event: ExtensionMessages.msgGetMyRoomUrl }));
			});
		}

		changeFocusedTab(tabID) {
			chrome.tabs.update(tabID, { active: true });
		}

		setupTabCapture(connectionIndex = 0) {
			chrome.tabs.query({ active: true, currentWindow: true }, activeTabs => {
				const currentTab = activeTabs[0];

				this.sendAnalyticEvent({
					clientGeneric: true,
					externalType: 'StartingTabcast',
					eventType: AnalyticsEventTypes.keyTabcastStarting,
					externalCategory: AnalyticsEventTypes.keyCategoryFeature,
					eventData: {
						tabUrl: currentTab.url,
						tabTitle: currentTab.title
					}
				});
			});

			const func = this._extensionState === ExtensionStates.Running ? this._replaceStreams.bind(this) : this._startCapture.bind(this);
			func().then(stream => {
				this._tabStream = stream;
				const activeRoomsConnections = this._getActiveRoomsConnections();
				if (activeRoomsConnections.length === 0) {
					this._startTabCaptureTimeout();
					this._extensionState = ExtensionStates.Starting;
					this._getMyRoomUrlFromServer().then(roomUrl => {
						if (!roomUrl) {
							this.stopTabCapture();
							return;
						}
						chrome.tabs.create({ url: roomUrl }, newTab => {});
					});
				} else {
					this._tabCaptureStarted(activeRoomsConnections[connectionIndex]);
				}
			});
		}

		_replaceStreams() {
			this._sendMessage({
				event: ExtensionMessages.msgReplaceStreams
			});

			for (const webrtcSession of this._webrtcSessions.values()) {
				webrtcSession.destroy();
			}

			this._setCapturedTab(null);

			if (this._tabStream) {
				const videoTracks = this._tabStream.getVideoTracks();
				if (videoTracks && videoTracks.length > 0) {
					videoTracks[0].onended = null;
					videoTracks[0].stop();
				}

				const audioTracks = this._tabStream.getAudioTracks();
				if (audioTracks && audioTracks.length > 0) {
					audioTracks[0].stop();
				}

				this._tabStream = null;
			}

			this._webrtcSessions.clear();

			return this._startCapture();
		}

		_getActiveRoomsConnections() {
			const activeRoomsConnections = [];
			if (this._connections) {
				for (const connection of this._connections.values()) {
					if (connection.getRoomId()) {
						activeRoomsConnections.push(connection);
					}
				}
			}

			return activeRoomsConnections;
		}

		_onConnectionRoomChanged(connection, msg) {

			connection.setRoomData(msg);

			if (this._extensionState === ExtensionStates.Starting && connection.getRoomId()) {
				this._tabCaptureStarted(connection);
			}
		}

		_onRestartWebrtcConnection(connection, msg) {
			this._removeWebrtcSession(msg.webrtcId);
			this._tabCaptureStarted(this._screencasterConnection, false);
		}

		_removeWebrtcSession(webrtcId) {
			if (!webrtcId) {
				// console.log('No webrtc id')
				return;
			}

			const webrtcSession = this._webrtcSessions.get(webrtcId);
			if (!webrtcSession) {
				// console.log('No webrtcSession');
				return;
			}

			webrtcSession.destroy();
			this._webrtcSessions.delete(webrtcId);
		}

		_onWebrtcConnectionFailed(webrtcId) {
			this._sendMessage({
				event: ExtensionMessages.msgWebrtcConnectionFailed,
				message: {
					webrtcId: webrtcId
				}
			});
		}

		_onUpdateExtensionState(connection, msg) {
			if (msg.state === ExtensionStates.Disabled) {
				if (this._extensionState !== ExtensionStates.Idle) {
					this.stopTabCapture();
				}
				this._extensionState = ExtensionStates.Disabled;
			} else if (msg.state === ExtensionStates.Enabled) {
				if (this._extensionState === ExtensionStates.Disabled) {
					this._extensionState = ExtensionStates.Idle;
				}
			}
			// console.info('connectiom state updated');
		}

		_setCapturedTab(tab) {
			if (this._capturedTabUpdated) {
				chrome.tabs.onUpdated.removeListener(this._capturedTabUpdated);
				this._capturedTabUpdated = null;
			}

			this._capturedTabId = tab ? tab.id : null;

			if (this._capturedTabId) {
				this._capturedTabUpdated = (tabId, changes, newTab) => {
					if (tabId !== this._capturedTabId) {
						return;
					}

					const updateContent = changes.status === 'complete' || tab.status === 'complete' && changes.title;

					if (!updateContent) {
						return;
					}

					this._sendMessage({
						event: ExtensionMessages.msgTabContentChanged,
						message: {
							url: newTab.url,
							title: newTab.title
						}
					});

					this.sendAnalyticEvent({
						clientGeneric: true,
						externalType: 'tabcastContentChanged',
						eventType: AnalyticsEventTypes.keyTabcastContentChanged,
						externalCategory: AnalyticsEventTypes.keyCategoryFeature,
						eventData: {
							tabUrl: newTab.url,
							tabTitle: newTab.title
						}
					});
				};

				chrome.tabs.onUpdated.addListener(this._capturedTabUpdated);
			}
		}

		_showFeedbackPopup() {
			if (this._connections.size === 0) {
				chrome.tabs.create({ url: 'https://www.rabb.it/contact-us' });
			} else {
				for (const connection of this._connections) {
					this._sendMessageToConnection(connection[1], {
						event: ExtensionMessages.msgShowFeedback,
						message: {
							show: true
						}
					});
				}
			}
		}

		_startTabCaptureTimeout() {
			const that = this;
			this._stopTabCaptureTimeout();
			this._tabCaptureTimeout = setTimeout(() => {
				that._tabCaptureTimeout = null;
				that.stopTabCapture();
			}, this._tabCaptureTimeoutValue);
		}

		_stopTabCaptureTimeout() {
			if (!this._tabCaptureTimeout) {
				return;
			}

			clearTimeout(this._tabCaptureTimeout);
			this._tabCaptureTimeout = null;
		}

		_onScreencastStarted() {
			const currentSettings = this._settings.getCurrentSettings();
			this._stopTabCaptureTimeout();
			this._sendCreateMediaSession(currentSettings.bitrate);
		}

		sendAnalyticEvent(eventMessage) {
			for (const connection of this._connections) {
				this._sendMessageToConnection(connection[1], {
					event: ExtensionMessages.msgAnalyticEvent,
					message: eventMessage
				});
			}
		}

		stealRemote() {
			// console.error('steal', connection);
			for (const connection of this._connections) {
				this._sendMessageToConnection(connection[1], {
					event: ExtensionMessages.msgRequestStealRemote,
					message: {}
				});
			}
		}

		checkConnections() {
			// check that tabs are connected
			chrome.tabs.query({}, tabs => {
				for (const tab of tabs) {
					if (tab.url.indexOf(this._config.getServerHostUrl()) >= 0) {
						// tab ID ${tab.id} is in ${this._config.getServerHostUrl()} domain, check to be sure we are connected to it
						let tabConnected = false;
						for (const [key, value] of this._connections) {
							if (key === tab.id) {
								// tab connected
								tabConnected = true;
							}
						}

						if (!tabConnected) {
							// tab disconnected, send message to refresh room data
							chrome.tabs.sendMessage(tab.id, ExtensionMessages.msgExtensionPresent);
						}
					}
				}
			});
		}

		_setupPolling() {
			if (this._roomRefreshPoll !== null) {
				clearTimeout(this._roomRefreshPoll);
				this._roomRefreshPoll = null;
			}
			this._roomRefreshPoll = setInterval(this.checkConnections.bind(this), 10000);
		}

		_sendCreateMediaSession(bitrate) {
			if (!this._tabStream) {
				console.error('No tab stream???');
				return;
			}

			const mediaTypes = new Array();

			const videoTracks = this._tabStream.getVideoTracks();
			if (videoTracks && videoTracks.length > 0) {
				mediaTypes.push('Video');
			}

			const audioTracks = this._tabStream.getAudioTracks();
			if (audioTracks && audioTracks.length > 0) {
				mediaTypes.push('Audio');
			}

			this._sendMessage({
				event: ExtensionMessages.msgCreateMediaSession,
				message: {
					constantBitrate: bitrate * 1024,
					mediaTypes: mediaTypes
				}
			});
		}

		_setupStreamEvents(stream) {
			const videoTracks = stream.getVideoTracks();
			if (videoTracks && videoTracks.length > 0) {
				videoTracks[0].onended = () => {
					this.stopTabCapture();
				};
			}
		}
	}

	module.exports = ExtensionController;

/***/ },
/* 14 */
/***/ function(module, exports) {

	'use strict';

	class Config {
		constructor() {
			this._server = new Map();
			this._env = '';
		}

		getEnvironment() {
			return this._env;
		}

		getServerHostUrl() {
			return this._server.get('hostUrl');
		}

		getServerDataHttp() {
			return this._server.get('dataHttp');
		}

		_processConfigData(data) {
			if (data.server && data.server.hostUrl) {
				this._server.set('hostUrl', data.server.hostUrl);
			}
			if (data.server && data.server.dataHttp) {
				this._server.set('dataHttp', data.server.dataHttp);
			}
			if (data.env) {
				this._env = data.env;
			}
		}

		loadConfigFile(fileName) {
			return new Promise((resolve, reject) => {
				const request = new XMLHttpRequest();
				request.onload = () => {
					let data = {};
					if (request.status === 200 && request.response) {
						try {
							data = JSON.parse(request.response);
						} catch (err) {
							// console.log(`Invalid json file: ${fileName}`);
						}
					}
					resolve(this._processConfigData(data));
				};

				request.onerror = () => {
					// console.log(`Error loading file: ${fileName}`);
					resolve(this._processConfigData({}));
				};

				request.open("GET", chrome.extension.getURL(fileName), true);
				request.send();
			});
		}
	}

	module.exports = Config;

/***/ },
/* 15 */
/***/ function(module, exports) {

	class Settings {
		constructor(values = {}) {
			this.width = this._ensureValue(values.width, 1280);
			this.height = this._ensureValue(values.height, 720);
			this.fps = this._ensureValue(values.fps, 24);
			this.bitrate = this._ensureValue(values.bitrate, 2000);
			this.presetOption = this._ensureValue(values.presetOption, 720);
		}

		getCurrentSettings() {
			return {
				width: this.width,
				height: this.height,
				fps: this.fps,
				bitrate: this.bitrate,
				presetOption: this.presetOption
			};
		}

		clone() {
			const settings = new Settings(this.getCurrentSettings());
			return settings;
		}

		saveSettings(newSettings) {
			return new Promise(resolve => {
				chrome.storage.sync.set(newSettings, () => {
					this.loadSettings().then(() => {
						resolve();
					});
				});
			});
		}

		loadSettings() {
			return new Promise(resolve => {
				chrome.storage.sync.get(null, values => {
					this.width = this._ensureValue(values.width, 1280);
					this.height = this._ensureValue(values.height, 720);
					this.fps = this._ensureValue(values.fps, 24);
					this.bitrate = this._ensureValue(values.bitrate, 2000);
					this.presetOption = this._ensureValue(values.presetOption, 720);
					resolve(values);
				});
			});
		}

		_ensureValue(value, defaultValue) {
			return Number(value === 0 ? 0 : value || defaultValue);
		}

	}

	module.exports = Settings;

/***/ },
/* 16 */
/***/ function(module, exports) {

	class WebpageConnection {
		constructor(connectionId, connection) {
			this._roomId = null;
			this._roomName = '';
			this._roomCreatorId = 0;
			this._roomCreatorAvatar = null;
			this._hasRemote = false;
			this._canStealRemote = false;
			this._connectionId = connectionId;
			this._connection = connection;
			this._hasScreencast = false;
			this._controllerUsername = '';
			this.onMessage = null;
			this._onMessage = null;
			this.onDisconnect = null;
			this._onDisconnect = null;
		}

		addOnMessageListener(listener) {
			if (this.onMessage) {
				// console.log('WebpageConnection: Only 1 onMessage listener allowed');
				return;
			}

			this.onMessage = listener;
			this._onMessage = event => {
				if (this.onMessage) {
					this.onMessage(this, event);
				}
			};

			this._connection.onMessage.addListener(this._onMessage.bind(this));
		}

		removeOnMessageListener() {
			this.onMessage = null;
			this._connection.onMessage.removeListener(this._onMessage.bind(this));
		}

		addOnDisconnectListener(listener) {
			if (this.onDisconnect) {
				// console.log('WebpageConnection: Only 1 onDisconnect listener allowed');
				return;
			}

			this.onDisconnect = listener;
			this._onDisconnect = event => {
				this._connection = null;
				if (this.onDisconnect) {
					this.onDisconnect(this, event);
				}
			};

			this._connection.onDisconnect.addListener(this._onDisconnect.bind(this));
		}

		removeOnDisconnectListener() {
			this.onDisconnect = null;
			if (this._connection) {
				this._connection.onDisconnect.removeListener(this._onDisconnect.bind(this));
			}
		}

		getConnectionId() {
			return this._connectionId;
		}

		send(msg) {
			if (!this._connection) {
				// console.log('WebpageConnection: No Connection');
				return;
			}

			this._connection.postMessage(msg);
		}

		getTabId() {
			if (this._connectionId) {
				return this._connectionId;
			}
			if (this._connection) {
				return this._connection.sender.tab.id;
			}

			return -1;
		}

		getRoomId() {
			return this._roomId;
		}

		setRoomId(roomId) {
			this._roomId = roomId;
		}

		getRoomName() {
			return this._roomName;
		}

		userHasRemote() {
			return this._hasRemote;
		}

		canStealRemote() {
			return this._canStealRemote;
		}

		hasScreencast() {
			return this._hasScreencast;
		}

		setRoomData(_roomData) {
			const roomData = _roomData || {};
			this._roomName = roomData.roomName;
			this._roomId = roomData.roomId;
			this._roomCreatorId = roomData.creatorId;
			this._roomCreatorAvatar = roomData.creatorAvatar;
			this._hasScreencast = roomData.hasScreencast;
			this._hasRemote = roomData.hasRemote;
			this._canStealRemote = roomData.canStealRemote;
			this._controllerUsername = roomData.controllerUsername;
			this._tabId = this.getTabId();
		}

		getRoomData() {
			return {
				roomId: this._roomId,
				roomName: this._roomName,
				roomCreatorId: this._roomCreatorId,
				roomCreatorAvatar: this._roomCreatorAvatar,
				hasScreencast: this._hasScreencast,
				hasRemote: this._hasRemote,
				canStealRemote: this._canStealRemote,
				controllerUsername: this._controllerUsername,
				tabId: this._tabId
			};
		}

		disconnect() {
			if (this._connection) {
				this.removeOnDisconnectListener();
				this.removeOnMessageListener();
				this._connection.disconnect();
				this._connection = null;
			}
		}
	}

	module.exports = WebpageConnection;

/***/ },
/* 17 */
/***/ function(module, exports, __webpack_require__) {

	'use strict';

	var _classCallCheck2 = __webpack_require__(18);

	var _classCallCheck3 = _interopRequireDefault(_classCallCheck2);

	var _NetworkMessageTypes = __webpack_require__(19);

	var _NetworkMessageTypes2 = _interopRequireDefault(_NetworkMessageTypes);

	function _interopRequireDefault(obj) { return obj && obj.__esModule ? obj : { 'default': obj }; }

	// eslint-disable-line

	var ExtensionMessageTypes = function ExtensionMessageTypes() {
	  (0, _classCallCheck3['default'])(this, ExtensionMessageTypes);
	};

	ExtensionMessageTypes.msgCreateMediaSession = _NetworkMessageTypes2['default'].msgCreateMediaSession;
	ExtensionMessageTypes.msgMediaSessionOffer = _NetworkMessageTypes2['default'].msgMediaSessionOffer;
	ExtensionMessageTypes.msgMediaSessionAnswer = _NetworkMessageTypes2['default'].msgMediaSessionAnswer;
	ExtensionMessageTypes.msgMediaSessionState = _NetworkMessageTypes2['default'].msgMediaSessionState;
	ExtensionMessageTypes.msgStopScreenCapture = _NetworkMessageTypes2['default'].msgStopScreenCapture;
	ExtensionMessageTypes.msgUpdateConstantBitrate = _NetworkMessageTypes2['default'].msgUpdateConstantBitrate;
	ExtensionMessageTypes.msgDestroyMediaSession = _NetworkMessageTypes2['default'].msgDestroyMediaSession;
	ExtensionMessageTypes.msgGetOpenedTabs = 'extension.getOpenedTabs';
	ExtensionMessageTypes.msgSetupTabCapture = 'extension.setupTabCapture';
	ExtensionMessageTypes.msgExtensionPresent = 'extension.extensionPresent';
	ExtensionMessageTypes.msgRoomChanged = 'extension.roomChanged';
	ExtensionMessageTypes.msgWebrtcConnectionFailed = 'extension.webrtcConnectionFailed';
	ExtensionMessageTypes.msgRestartWebrtcConnection = 'extension.restartWebrtcConnection';
	ExtensionMessageTypes.msgUpdateExtensionState = 'extension.updateExtensionState';
	ExtensionMessageTypes.msgTabContentChanged = _NetworkMessageTypes2['default'].msgTabContentChanged;
	ExtensionMessageTypes.msgStartScreencast = 'extension.startScreencast';
	ExtensionMessageTypes.msgScreencastStarted = 'extension.screencastStarted';
	ExtensionMessageTypes.msgScreencastController = 'extension.screencastController';
	ExtensionMessageTypes.msgAnalyticEvent = 'extension.analyticEvent';
	ExtensionMessageTypes.msgRequestStealRemote = 'extension.requestStealRemote';

	ExtensionMessageTypes.msgShowFeedback = 'extension.showFeedbackForm';
	ExtensionMessageTypes.msgShowFAQs = 'extension.showFAQPage';

	ExtensionMessageTypes.msgReplaceStreams = 'extension.replaceStreams';
	ExtensionMessageTypes.msgRefreshRoomData = 'extension.refreshRoomData';

	ExtensionMessageTypes.msgGetMyRoomUrl = 'room.getMyRoomUrl';

	module.exports = ExtensionMessageTypes;

/***/ },
/* 18 */
/***/ function(module, exports) {

	"use strict";

	exports.__esModule = true;

	exports.default = function (instance, Constructor) {
	  if (!(instance instanceof Constructor)) {
	    throw new TypeError("Cannot call a class as a function");
	  }
	};

/***/ },
/* 19 */
/***/ function(module, exports) {

	'use strict';

	var NetworkMessageTypes = {};
	NetworkMessageTypes.msgDisplayNotification = 'session.displayNotification';

	// Friends
	NetworkMessageTypes.msgFriendUpdate = 'session.friendUpdate';

	// Authorization
	NetworkMessageTypes.msgWelcome = 'authorization.welcome';

	// Authentication
	NetworkMessageTypes.msgRegister = 'authorization.register';
	NetworkMessageTypes.msgLogin = 'authorization.login';
	NetworkMessageTypes.msgAuthorize = 'authorization.authorize';
	NetworkMessageTypes.msgLogout = 'authorization.logout';
	NetworkMessageTypes.msgResetPassword = 'authorization.resetPassword';
	NetworkMessageTypes.msgVerifyResetToken = 'authorization.verifyResetToken';
	NetworkMessageTypes.msgResetPasswordWithToken = 'authorization.resetPasswordWithToken';
	NetworkMessageTypes.msgUpdatePassword = 'authorization.updatePassword';
	NetworkMessageTypes.resendVerificationEmail = 'authorization.resendVerificationEmail';
	NetworkMessageTypes.msgThirdParty = 'authorization.thirdParty';

	// Invite Email
	NetworkMessageTypes.msgCreateInviteToScreencastLink = 'invite.createInviteToScreencastLink';
	NetworkMessageTypes.msgCreateInviteToRoomLink = 'invite.createInviteToRoomLink';
	NetworkMessageTypes.msgCreateInviteToFriendLink = 'invite.createInviteToFriendLink';
	NetworkMessageTypes.msgCheckInviteToFriendLink = 'invite.checkInviteToFriendLink';
	NetworkMessageTypes.msgConsumeInviteToFriendLink = 'invite.consumeInviteToFriendLink';
	NetworkMessageTypes.msgGetInviteLinkParams = 'invite.getInviteLinkParams';
	NetworkMessageTypes.msgSendInviteEmails = 'invite.sendInviteEmails';
	NetworkMessageTypes.msgInviteSent = 'invite.inviteSent';
	NetworkMessageTypes.msgInviteFriendToRoom = 'invite.inviteFriendToRoom';
	NetworkMessageTypes.msgInviteUsersToRoom = 'invite.inviteUsersToRoom';

	NetworkMessageTypes.msgFacebookProfile = 'facebook_profile';

	// User
	NetworkMessageTypes.msgGetProfile = 'profile.getProfile';
	NetworkMessageTypes.msgUpdateProfile = 'profile.updateProfile';
	NetworkMessageTypes.msgChangePassword = 'profile.changePassword';
	NetworkMessageTypes.msgClearPendingEmail = 'profile.clearPendingEmail';
	NetworkMessageTypes.msgUploadProfileImage = 'profile.uploadProfileImage';
	NetworkMessageTypes.msgRemoveProfileImage = 'profile.removeProfileImage';
	NetworkMessageTypes.resendVerificationSms = 'profile.resendVerificationSms';
	NetworkMessageTypes.msgSearchForUsername = 'profile.searchProfile';
	NetworkMessageTypes.msgSearchForProfiles = 'profile.searchForProfiles';
	NetworkMessageTypes.msgGetProfileToken = 'profile.getProfileToken';
	NetworkMessageTypes.msgSetOnlineStatusSetting = 'profile.setOnlineStatusSetting';
	NetworkMessageTypes.msgSetHideMeSetting = 'profile.setHideMeSetting';
	NetworkMessageTypes.msgAddBookmark = 'bookmarks.addBookmark';
	NetworkMessageTypes.msgDeleteBookmark = 'bookmarks.deleteBookmark';
	NetworkMessageTypes.msgFetchAllBookmarks = 'bookmarks.fetchAllBookmarks';
	NetworkMessageTypes.msgReplaceAllBookmarks = 'bookmarks.replaceAllBookmarks';
	NetworkMessageTypes.msgReplaceBookmark = 'bookmarks.replaceBookmark';
	NetworkMessageTypes.msgBookmarkCurrentRoomContentUrl = 'bookmarks.bookmarkCurrentRoomContentUrl';

	NetworkMessageTypes.msgGetContentForYou = 'contentSourceRanking.getContentForYou';

	NetworkMessageTypes.msgUpdateNewLookOnboarding = 'uxProfile.updateNewLookOnboarding';
	NetworkMessageTypes.msgSetScreencastQualityTrialExpiration = 'uxProfile.setScreencastQualityTrialExpiration';
	NetworkMessageTypes.msgUpdateUxProfile = 'uxProfile.updateUxProfile';

	NetworkMessageTypes.msgSetInterestTagIds = 'user.setInterestTagIds';
	NetworkMessageTypes.msgGetInterestTags = 'content.tagsUserCanSelect';

	// Error
	NetworkMessageTypes.msgError = 'error';
	NetworkMessageTypes.msgAccessDenied = 'access_denied';

	// Campaign
	NetworkMessageTypes.msgSubscribeToWebsiteList = 'campaign.subscribeToWebsiteList';
	NetworkMessageTypes.msgSubscribeToInterestedList = 'campaign.subscribeToInterestedList';

	// Url Shortener
	NetworkMessageTypes.msgShortenUrl = 'urlShortener.shortenUrl';

	// Conversations
	NetworkMessageTypes.msgConversation = 'messaging.conversation';
	NetworkMessageTypes.msgConversationUserAdded = 'messaging.conversationUserAdded';
	NetworkMessageTypes.msgConversationUserRemoved = 'messaging.conversationUserRemoved';
	NetworkMessageTypes.msgConversationUsersAdded = 'messaging.conversationUsersAdded';
	NetworkMessageTypes.msgGetConversationWithUsers = 'messaging.getConversationWithUsers';

	NetworkMessageTypes.msgConversationCacheSync = 'messaging.conversationCacheSync';

	NetworkMessageTypes.msgConversationMessage = 'messaging.conversationMessage';
	NetworkMessageTypes.msgSendConversationMessage = 'messaging.sendConversationMessage';
	NetworkMessageTypes.msgRequestConversationMessages = 'messaging.requestConversationMessages';

	NetworkMessageTypes.msgSendMessageUnregisteredUser = 'messaging.sendMessageUnregisteredUser';

	NetworkMessageTypes.msgMarkConversationLastReadTimestamp = 'messaging.markConversationLastReadTimestamp';
	NetworkMessageTypes.msgMarkHistoryReset = 'messaging.markLastHistoryReset';

	NetworkMessageTypes.msgSendConversationActivity = 'messaging.sendConversationActivity';
	NetworkMessageTypes.msgConversationActivity = 'messaging.conversationActivity';

	NetworkMessageTypes.msgCreateStatus = 'messaging.createStatus';
	NetworkMessageTypes.msgDeleteStatus = 'messaging.deleteStatus';
	NetworkMessageTypes.msgDeleteConversationMessage = 'messaging.deleteConversationMessage';
	NetworkMessageTypes.msgUpdateConversationMessage = 'messaging.updateConversationMessage';

	NetworkMessageTypes.msgLikeConversationMessage = 'messaging.likeConversationMessage';

	NetworkMessageTypes.msgRequestConversationMessageFromNotification = 'messaging.requestConversationMessageFromNotification';

	// Group Chat
	NetworkMessageTypes.msgCreateGroupConversation = 'messaging.createGroupConversation';
	NetworkMessageTypes.msgAddUsersToGroupConversation = 'messaging.addUsersToGroupConversation';
	NetworkMessageTypes.msgLeaveGroupConversation = 'messaging.leaveGroupConversation';
	NetworkMessageTypes.msgDeleteGroupConversation = 'messaging.deleteGroupConversation';
	NetworkMessageTypes.msgKickFromGroupConversation = 'messaging.kickFromGroupConversation';
	NetworkMessageTypes.msgSetConversationName = 'messaging.setConversationName';

	// Notifications
	NetworkMessageTypes.msgNotification = 'notification.notification';
	NetworkMessageTypes.msgDeleteNotification = 'notification.deleteNotification';
	NetworkMessageTypes.msgSystemNotification = 'notification.systemNotification';
	NetworkMessageTypes.msgSystemMaintenance = 'notification.systemMaintenance';
	NetworkMessageTypes.msgNotificationMarkAsRead = 'notification.markAsRead';
	NetworkMessageTypes.msgFlagAction = 'notification.flagAction';

	// Session Subscription
	NetworkMessageTypes.msgResynchronize = 'subscription.resynchronize';
	NetworkMessageTypes.msgSynchronize = 'subscription.synchronize';
	NetworkMessageTypes.msgSubscriptionEntityDeleted = 'subscription.entityDeleted';
	NetworkMessageTypes.msgSubscriptionFieldsUpdated = 'subscription.fieldsUpdated';
	NetworkMessageTypes.msgSubscriptionValuesAdded = 'subscription.valuesAdded';
	NetworkMessageTypes.msgSubscriptionValuesRemoved = 'subscription.valuesRemoved';

	// Rooms
	NetworkMessageTypes.msgGetRoomInfo = 'room.getRoomInfo';
	NetworkMessageTypes.msgCreateRoom = 'room.createRoom';
	NetworkMessageTypes.msgEnterRoom = 'room.enterRoom';
	NetworkMessageTypes.msgLeaveRoom = 'room.leaveRoom';
	NetworkMessageTypes.msgTestEnterRoom = 'room.testEnterRoom';
	NetworkMessageTypes.msgDoneWithRooms = 'room.doneWithRooms';
	NetworkMessageTypes.msgKickOutUser = 'room.kickOutUser';
	NetworkMessageTypes.msgKickedOut = 'room.kickedOut';
	NetworkMessageTypes.msgEndChat = 'room.endChat';
	NetworkMessageTypes.msgChatEnded = 'room.chatEnded';
	NetworkMessageTypes.msgAddUsernameToRoom = 'room.addUsernameToRoom';
	NetworkMessageTypes.msgRequestLockedRoomAccess = 'room.requestLockedRoomAccess';
	NetworkMessageTypes.msgLockedRoomAccessGranted = 'room.lockedRoomAccessGranted';
	NetworkMessageTypes.msgRequestFullRoomAccess = 'room.requestFullRoomAccess';
	NetworkMessageTypes.msgFullRoomAccessGranted = 'room.fullRoomAccessGranted';
	NetworkMessageTypes.msgTabContentChanged = 'room.tabContentChanged';

	NetworkMessageTypes.msgLockRoom = 'room.lockRoom';
	NetworkMessageTypes.msgUnlockRoom = 'room.unlockRoom';
	NetworkMessageTypes.msgJoinRoom = 'room.joinRoom';
	NetworkMessageTypes.msgStopMonitoringNetworkStatus = 'room.stopMonitoringNetworkStatus';
	NetworkMessageTypes.msgSetSelfcast = 'room.setSelfcast';
	NetworkMessageTypes.msgRoomState = 'room.roomState';

	NetworkMessageTypes.subscriptionUserEvents = 'userEvents';
	NetworkMessageTypes.msgRoomFull = 'room.roomFull';
	NetworkMessageTypes.msgUserJoinedFullGroup = 'room.userJoinedFullGroup';

	// Live Rooms
	NetworkMessageTypes.msgGetLiveRooms = 'liveRooms.getLiveRooms';
	NetworkMessageTypes.msgSetLive = 'liveRooms.setLive';
	NetworkMessageTypes.msgShowContentNotAllowed = 'liveRooms.showContentNotAllowed';
	NetworkMessageTypes.msgShowGoLivePrompt = 'liveRooms.showGoLivePrompt';
	NetworkMessageTypes.msgCheckLiveAllowed = 'liveRooms.checkLiveAllowed';

	// Session
	NetworkMessageTypes.msgScreencastKilled = 'session.screencastKilled';
	NetworkMessageTypes.msgNagOrder = 'session.nagOrder';
	NetworkMessageTypes.msgParticipationSettings = 'session.participationSettings';
	NetworkMessageTypes.msgCreateAndAuthorizeSession = 'session.createAndAuthorize';
	NetworkMessageTypes.msgAuthorizeContactsRequest = 'session.authorizeContactsRequest';
	NetworkMessageTypes.msgForceClean = 'session.forceClean';
	NetworkMessageTypes.msgContactDetails = 'session.contactDetails';
	NetworkMessageTypes.msgParticipationStart = 'session.participationStart';
	NetworkMessageTypes.msgIdleStatus = 'session.idleStatus';
	NetworkMessageTypes.msgWebAppState = 'session.webAppState';

	NetworkMessageTypes.msgStartScreenCapture = 'web.startScreenCapture';
	NetworkMessageTypes.msgStopScreenCapture = 'web.stopScreenCapture';
	NetworkMessageTypes.msgTakeScreencaptureControl = 'web.takeScreencaptureControl';
	NetworkMessageTypes.msgReleaseScreencaptureControl = 'web.releaseScreencaptureControl';
	NetworkMessageTypes.msgControlClaimedByOwner = 'web.controlClaimedByOwner';
	NetworkMessageTypes.msgUpdateClipboardScreenCaptureSession = 'web.updateClipboardScreenCaptureSession';
	NetworkMessageTypes.msgScreencastControlTaken = 'web.screencastControlTaken';
	NetworkMessageTypes.msgControlRequestedScreenCaptureSession = 'web.screencastControlRequested';
	NetworkMessageTypes.msgRequestScrencaptureControl = 'web.requestScrencaptureControl';
	NetworkMessageTypes.msgNotifyStillWatchingScreencast = 'web.notifyStillWatchingScreencast';
	NetworkMessageTypes.msgSwitchVideoQuality = 'web.switchVideoQuality';

	NetworkMessageTypes.msgStartBroadcast = 'broadcast.startBroadcast';
	NetworkMessageTypes.msgStopBroadcast = 'broadcast.stopBroadcast';

	NetworkMessageTypes.msgWriteAnalyticsEvent = 'analytics.writeAnalyticsEvent';

	NetworkMessageTypes.msgCreateMediaSession = 'web.createMediaSession';
	NetworkMessageTypes.msgDestroyMediaSession = 'web.destroyMediaSession';
	NetworkMessageTypes.msgMediaSessionIce = 'web.mediaSessionIce';
	NetworkMessageTypes.msgStartStreamingMediaSession = 'web.startStreamingMediaSession';
	NetworkMessageTypes.msgStopStreamingMediaSession = 'web.stopStreamingMediaSession';
	NetworkMessageTypes.msgUpdateStreamingMediaSession = 'web.updateStreamingMediaSession';
	NetworkMessageTypes.msgResetMediaSession = 'web.resetMediaSession';
	NetworkMessageTypes.msgMediaSessionOffer = 'web.mediaSessionOffer';
	NetworkMessageTypes.msgMediaSessionAnswer = 'web.mediaSessionAnswer';
	NetworkMessageTypes.msgMediaSessionState = 'web.mediaSessionState';
	NetworkMessageTypes.msgSetMediaQuality = 'web.setMediaQuality';
	NetworkMessageTypes.msgSetMediaBitrate = 'web.setMediaBitrate';
	NetworkMessageTypes.msgInvalidWebrtcCall = 'web.invalidWebrtcCall';
	NetworkMessageTypes.msgUpdateStreamingMediaSession = 'web.updateStreamingMediaSession';
	NetworkMessageTypes.msgVerifyMediaSubscription = 'web.verifyMediaSubscription';
	NetworkMessageTypes.msgToggleVideochat = 'web.toggleVideochat';
	NetworkMessageTypes.msgUpdateConstantBitrate = 'web.updateConstantBitrate';
	NetworkMessageTypes.msgRestrictedContentAccessed = 'web.restrictedContentAccessed';

	NetworkMessageTypes.msgGetIceServers = 'webConfig.getIceServers';

	NetworkMessageTypes.msgSendFriendRequest = 'user.sendFriendRequest';
	NetworkMessageTypes.msgAcceptFriendRequest = 'user.acceptFriendRequest';
	NetworkMessageTypes.msgRejectFriendRequest = 'user.rejectFriendRequest';
	NetworkMessageTypes.msgRemoveFriend = 'user.removeFriend';
	NetworkMessageTypes.msgBlockUser = 'user.blockUser';
	NetworkMessageTypes.msgUnblockUser = 'user.unblockUser';

	NetworkMessageTypes.msgContentRestrictionRequest = 'content.contentRestrictionRequest';
	NetworkMessageTypes.msgContentRestrictionAnswer = 'content.contentRestrictionAnswer';

	NetworkMessageTypes.msgChangeCountry = 'session.changeCountry';
	NetworkMessageTypes.msgIceCandidates = 'session.iceCandidates';

	NetworkMessageTypes.msgGetFriendSuggestions = 'friendSuggestions.getFriendSuggestions';
	NetworkMessageTypes.msgRejectUserIdFromSuggestions = 'friendSuggestions.rejectUserIdFromSuggestions';

	NetworkMessageTypes.msgYoutubeGetPopular = 'youtube.getPopular';
	NetworkMessageTypes.msgYoutubeSearch = 'youtube.search';

	NetworkMessageTypes.msgSetWantsAudioVideo = 'session.setWantsAudioVideo';

	NetworkMessageTypes.msgStartGame = 'game.startGame';
	NetworkMessageTypes.msgStopGame = 'game.stopGame';

	NetworkMessageTypes.msgOneSignalRegisterDevice = 'devices.oneSignalRegisterDevice';

	NetworkMessageTypes.msgRegisterDevice = 'devices.registerDevice';
	NetworkMessageTypes.msgUnregisterDevice = 'devices.unregisterDevice';

	NetworkMessageTypes.msgGetEventImagePreviewAndTitle = 'scheduling.getImagePreviewAndTitle';
	NetworkMessageTypes.msgScheduleEvent = 'scheduling.scheduleEvent';
	NetworkMessageTypes.msgCancelEvent = 'scheduling.cancelEvent';
	NetworkMessageTypes.msgGetScheduledEvents = 'scheduling.getScheduledEvents';
	NetworkMessageTypes.msgRSVPToEvent = 'scheduling.rsvpToEvent';
	NetworkMessageTypes.msgStartEvent = 'scheduling.startEvent';

	module.exports = NetworkMessageTypes;

/***/ },
/* 20 */
/***/ function(module, exports) {

	class ExtensionStates {}

	ExtensionStates.Idle = 'idle';
	ExtensionStates.Starting = 'starting';
	ExtensionStates.Setup = 'setup';
	ExtensionStates.Running = 'running';
	ExtensionStates.Disabled = 'disabled';
	ExtensionStates.Enabled = 'enabled';

	module.exports = ExtensionStates;

/***/ },
/* 21 */
/***/ function(module, exports) {

	const defaultConstraints = {
		mandatory: {},
		optional: [{ googCpuOveruseDetection: true }, { googCpuOveruseEncodeUsage: true }, { googCpuUnderuseThreshold: 40 }, { googCpuOveruseThreshold: 65 }, { googImprovedWifiBwe: true }, { googSuspendBelowMinBitrate: false }, { googSkipEncodingUnusedStreams: true }]
	};

	class WebrtcSession {
		constructor(webrtcId, iceServers, stream) {
			this._webrtcId = webrtcId;
			this._iceServers = iceServers;
			this._stream = stream;
			this.onSignalingStateChange = null;
			this.onIceConnectionStateChange = null;
			this.onIceCandidate = null;

			this._createPeerConnection();
		}

		_createPeerConnection() {
			const configuration = {
				iceServers: this._iceServers
			};

			this._peerConnection = new webkitRTCPeerConnection(configuration, defaultConstraints);
			this._peerConnection.onsignalingstatechange = this._onSignalingStateChange.bind(this);
			this._peerConnection.oniceconnectionstatechange = this._onIceConnectionStateChange.bind(this);
			this._peerConnection.onicecandidate = this._onIceCandidate.bind(this);
			this._peerConnection.addStream(this._stream);
		}

		_onSignalingStateChange() {
			// console.log('_onSignalingStateChange: ' + JSON.stringify(this.getConnectionState()));
			if (this.onSignalingStateChange) {
				this.onSignalingStateChange();
			}
		}

		_onIceConnectionStateChange() {
			// console.log('_onIceConnectionStateChange: ' + JSON.stringify(this.getConnectionState()));
			if (this.onIceConnectionStateChange) {
				this.onIceConnectionStateChange();
			}
		}

		_onIceCandidate(evt) {
			if (this.onIceCandidate && evt && evt.candidate) {
				this.onIceCandidate(evt.candidate);
			}
		}

		setRemoteDescription(sessionDescription) {
			if (!this._peerConnection) {
				// console.log('setRemoteDescription : no _peerConnection');
				return;
			}

			return new Promise((resolve, reject) => {
				this._peerConnection.setRemoteDescription(new RTCSessionDescription(sessionDescription));
				resolve(sessionDescription);
			});
		}

		setLocalDescription(sessionDescription) {
			if (!this._peerConnection) {
				// console.log('setLocalDescription : no _peerConnection');
				return;
			}

			return new Promise((resolve, reject) => {
				this._peerConnection.setLocalDescription(new RTCSessionDescription(sessionDescription));
				resolve(sessionDescription);
			});
		}

		createAswer() {
			if (!this._peerConnection) {
				// console.log('createAswer : no _peerConnection');
				return;
			}

			return new Promise((resolve, reject) => {
				this._peerConnection.createAnswer(answer => {
					resolve(answer);
				}, error => {
					// console.log('createAswer error: ' + JSON.stringify(error));
					reject(error);
				});
			});
		}

		getConnectionState() {
			if (!this._peerConnection) {
				// console.log('getConnectionState : no _peerConnection');
				return null;
			}
			const connectionState = new Map();
			connectionState['signalingState'] = this._peerConnection.signalingState;
			connectionState['iceConnectionState'] = this._peerConnection.iceConnectionState;
			connectionState['iceGatheringState'] = this._peerConnection.iceGatheringState;

			return connectionState;
		}

		destroy() {
			if (!this._peerConnection) {
				return;
			}

			this.onSignalingStateChange = null;
			this.onIceConnectionStateChange = null;
			this.onIceCandidate = null;
			this._peerConnection.onsignalingstatechange = null;
			this._peerConnection.oniceconnectionstatechange = null;
			this._peerConnection.onicecandidate = null;
			this._peerConnection.close();
			this._peerConnection = null;
			this._webrtcId = null;
			this._iceServers = null;
			this._stream = null;
		}

		getWebrtcId() {
			return this._webrtcId;
		}
	}

	WebrtcSession.IceConnectionStates = {
		New: 'new',
		Checking: 'checking',
		Connected: 'connected',
		Completed: 'completed',
		Failed: 'failed',
		Disconnected: 'disconnected',
		Closed: 'closed'
	};

	module.exports = WebrtcSession;

/***/ },
/* 22 */
/***/ function(module, exports) {

	'use strict';

	Object.defineProperty(exports, "__esModule", {
	  value: true
	});
	var keys = {};

	keys.keyErrorConnectionLost = 'clientErrorConnectionLost';

	// Robot events indicate that an automated script is trying to use the site
	keys.keyRobotEmailInvite = 'clientRobotEmailInvite';
	keys.keyRobotFeedback = 'clientRobotFeedback';
	keys.keyRobotSignup = 'clientRobotSignup';
	keys.keyRobotLock = 'clientRobotLock';
	keys.keyRobotFull = 'clientRobotFull';

	keys.keyScreencastError = 'clientScreencastError';
	keys.keyScreencastNavigate = 'clientScreencastNavigate';
	keys.keyScreencastNavigateError = 'clientScreencastNavigateError';
	keys.keyScreencastNavigateSuccess = 'clientScreencastNavigateSuccess';
	keys.keyScreencastQueued = 'clientScreencastQueued';
	keys.keyScreencastReleaseControl = 'clientScreencastReleaseControl';
	keys.keyScreencastStart = 'clientScreencastStart';
	keys.keyScreencastStartSuccess = 'clientScreencastStartSuccess';
	keys.keyScreencastStop = 'clientScreencastStop';
	keys.keyScreencastStopped = 'clientScreencastStopped';
	keys.keyScreencastTakeControl = 'clientScreencastTakeControl';
	keys.keyScreencastWatching = 'clientScreencastWatching';

	keys.keyTabcastWatching = 'clientTabcastWatching';
	keys.keyTabcastStarting = 'clientTabcastStart';
	keys.keyTabcastContentChanged = 'clientTabcastContentChanged';
	keys.keyTabcastQueued = 'clientTabcastQueued';
	keys.keyTabcastStop = 'clientTabcastStop';
	keys.keyTabcastStopped = 'clientTabcastStopped';

	keys.keySigninSubmit = 'clientSigninSubmit';
	keys.keySigninSuccess = 'clientSigninSuccess';
	keys.keySignupSuccess = 'clientSignupSuccess';

	keys.keyChatGroupSizeChanged = 'clientChatGroupSizeChanged';
	keys.keyChatting = 'clientChatting';

	keys.keyInviteCopyLink = 'clientInviteCopyLink';
	keys.keyInviteSendEmail = 'clientInviteSendEmail';
	keys.keyInviteFacebook = 'clientInviteFacebook';
	keys.keyInviteTwitter = 'clientInviteTwitter';

	keys.keyDownStreamBandwidth = 'clientDownStreamBandwidth';

	keys.keyEnterFullScreen = 'clientEnterFullScreen';
	keys.keyChangeScreencastQuality = 'clientChangeScreencastQuality';

	keys.keyHideBubbles = 'clientHideBubbles';
	keys.keyShowBubbles = 'clientShowBubbles';

	keys.keyStartedSelfcast = 'startedSelfcast';

	keys.keyInvitedFriendFromFriendsList = 'invitedFriendFromFriendsList';

	keys.keyViewedContactFindPopup = 'clientViewedContactFindPopup';
	keys.keyContactFind = 'clientContactFind';
	keys.keyFriendSuggestion = 'clientFriendSuggestion';

	keys.keyViewedGroupChatPopup = 'clientViewedGroupChatPopup';
	keys.keyCreatedGroupChat = 'clientCreatedGroupChat';
	keys.keyViewedGroupChat = 'clientViewedGroupChat';
	keys.keyPostedGroupChat = 'clientPostedGroupChat';
	keys.keyLeftGroupChat = 'clientLeftGroupChat';
	keys.keyDeletedGroupChat = 'clientDeletedGroupChat';

	keys.keyEnteredMyRoom = 'clientEnteredMyRoom';
	keys.keyEnteredSomeoneElseRoom = 'clientEnteredSomeoneElseRoom';
	keys.keyUserAcquired = 'clientUserAcquired';

	keys.keyInRoomWithFriends = 'clientInRoomWithFriends';
	keys.keyInATextChatWithFriends = 'clientInATextChatWithFriends';

	keys.keyRTT = 'RTT';
	keys.keyInitialRTT = 'InitialRTT';
	keys.keyNormalRTT = 'NormalRTT';
	keys.keyLowBandwidthBannerShown = 'LowBandwidthBannerShown';
	keys.keyScreencastConnectionFailure = 'screencastConnectionFailure';
	keys.keyUploadFailure = 'uploadFailure';
	keys.keyDownloadFailure = 'downloadFailure';
	keys.keyScreencastConnectionIssue = 'screencastConnectionIssue';
	keys.keyUploadIssue = 'uploadIssue';
	keys.keyDownloadIssue = 'downloadIssue';
	keys.keyScreencastConnectionSuccess = 'screencastConnectionSuccess';
	keys.keyUploadSuccess = 'uploadSuccess';
	keys.keyDownloadSuccess = 'downloadSuccess';
	keys.keyEnteredBasicMode = 'EnteredBasicMode';
	keys.keyRetryPopupShown = 'RetryPopupShown';
	keys.keyRetryClicked = 'RetryClicked';
	keys.keyRetrySuccess = 'RetrySuccess';
	keys.keyRetryFailure = 'RetryFailure';
	keys.keyClickedCamera = 'ClickedCamera';
	keys.keyClickedMic = 'ClickedMic';

	keys.keyLikedPost = 'clientLikedPost';
	keys.keyPostedToActivityFeed = 'clientPostedToActivityFeed';

	keys.keyActivityFeedLikesAndMentionsViewed = 'clientActivityFeedLikesAndMentionsViewed';
	keys.keyClickedFeatureAnnouncementActivity = 'clickedFeatureAnnouncementActivity';
	keys.keyViewedPostPreviewMention = 'clientViewedPostPreviewMention';
	keys.keyClickedGoToMyRoom = 'ClickedGoToMyRoom';
	keys.keyClickedToRequestAccess = 'ClickedToRequestAccess';
	keys.keyClickedToSendMessage = 'ClickedToSendMessage';
	keys.keyClickedPinEveryone = 'clientClickedPinEveryone';
	keys.keyClickedUnpinEveryone = 'clientClickedUnpinEveryone';
	keys.keyClickedSignUp = 'clientClickedSignUp';
	keys.keyClickedSignIn = 'clientClickedSignIn';
	keys.keyClickedDisableVideoChat = 'ClickedDisableVideoChat';
	keys.keyClickedEnableVideoChat = 'ClickedEnableVideoChat';
	keys.keysNewUserAutoRedirect = 'NewUserAutoRedirect';

	keys.keysClientEnterNamePromptShown = 'clientEnterNamePromptShown';
	keys.keysClientAVPromptShown = 'clientAVPromptShown';
	keys.keysClientInvitePromptShown = 'clientInvitePromptShown';
	keys.keysClientFirstRoomShown = 'clientFirstRoomShown';
	keys.keysClientGameStarted = 'clientGameStarted';
	keys.keysClientGameJoined = 'clientGameJoined';

	keys.keyPageView = 'clientPageView';

	// rabbit pad
	keys.keyClickedLauchpadTab = 'clientClickedLauchpadTab';
	keys.keyClickedContent = 'clientClickedContent';
	keys.keyClickedSkip = 'ClickedSkip';

	// External Types
	keys.keyTypeClickedSignUp = 'ClickedSignUp';
	keys.keyClickedStartChat = 'ClickedStartChat';
	keys.keyFriendSuggestionsShown = 'FriendSuggestionsShown';
	keys.keyEnterNamePropmtShown = 'EnterNamePropmtShown';
	keys.keysEnterNameAVPromptShown = 'EnterNameAVPromptShown';
	keys.keysAVPromptShown = 'AVPromptShown';
	keys.keysInvitePromptShown = 'InvitePromptShown';
	keys.keysFirstRoomIntroShown = 'FirstRoomIntroShown';
	keys.keysChromeExtPopupClosed = 'ChromeExtPopupClosed';
	keys.keysChromeExtPopupClicked = 'ChromeExtPopupClicked';
	keys.keysGameStarted = 'StartedGame';
	keys.keysGameJoined = 'JoinedGame';

	keys.keysNewRbTail = 'NewRbTail';
	keys.keyEnteredAnyRoom = 'EnteredAnyRoom';

	// Experiment test
	keys.keysSimpleOnboardingWelcomeShown = 'SimpleOnboardingWelcomeShown';
	keys.keysSimpleOnboardingWatchShown = 'SimpleOnboardingWatchShown';
	keys.keysSimpleOnboardingInviteMessageShown = 'SimpleOnboardingInviteMessageShown';
	keys.keysSimpleOnboardingLaunchpadMessageShown = 'SimpleOnboardingLaunchpadMessageShown';
	keys.keysSimpleOnboardingLaunchpadShown = 'SimpleOnboardingLaunchpadShown';
	keys.keysSimpleOnboardingLiveRoomMessageShown = 'SimpleOnboardingLiveRoomMessageShown';
	keys.keysSimpleOnboardingFeaturedMessageShown = 'SimpleOnboardingFeaturedMessageShown';
	keys.keysSimpleOnboardingComplete = 'SimpleOnboardingComplete';

	keys.keyTypePageView = 'PageView';

	// External Categories
	keys.keyCategorySignInUp = 'Sign in / up';
	keys.keyCategoryWithFriends = 'With Friends';
	keys.keyCategoryActivity = 'Activity';
	keys.keyCategoryAVMonitoring = 'AVMonitoring';
	keys.keyCategoryClickNavigation = 'Click - Navigation';
	keys.keyCategoryError = 'Error';
	keys.keyCategoryFeature = 'Feature';
	keys.keyCategoryFindFriends = 'Find friends';
	keys.keyCategoryHome = 'Home';
	keys.keyCategoryNavigation = 'Navigation';
	keys.keyCategorySession = 'Session';
	keys.keyCategoryRoomType = 'Room type';
	keys.keyCategoryUser = 'User';
	keys.keyCategoryPopup = 'Popup';
	keys.keyCategoryReferral = 'Referral';
	keys.keyCategoryLaunchpad = 'Launchpad';
	keys.keyCategoryInterests = 'Interests';
	keys.keyCategoryScheduledEvents = 'ScheduledEvents';

	// interests
	keys.keyClickedAddInterests = 'ClickedAddInterests';
	keys.keySeenInterestPicker = 'SeenInterestPicker';

	// Scheduled Events
	keys.keyClickedToCreateEvent = 'ClickedToCreateEvent';
	keys.keyCreatedEvent = 'CreatedEvent';
	keys.keyCanceledEvent = 'CanceledEvent';
	keys.keyClickedToRSVP = 'ClickedToRSVP';
	keys.keyClickedToUndoRSVP = 'ClickedToUndoRSVP';
	keys.keyShownStartEventPopup = 'ShownStartEventPopup';
	keys.keyStartedEvent = 'StartedEvent';

	exports['default'] = keys;
	module.exports = exports['default'];

/***/ }
/******/ ]);