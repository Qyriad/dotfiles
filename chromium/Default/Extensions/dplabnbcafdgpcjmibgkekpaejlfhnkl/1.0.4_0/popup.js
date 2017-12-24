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

	
	const RabbitPopup = __webpack_require__(31); // eslint-disable-line import/no-unresolved
	const popup = new RabbitPopup();
	popup.initalizePopup();

/***/ },
/* 1 */,
/* 2 */,
/* 3 */,
/* 4 */,
/* 5 */,
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
/* 7 */,
/* 8 */,
/* 9 */,
/* 10 */,
/* 11 */,
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
/* 13 */,
/* 14 */,
/* 15 */,
/* 16 */,
/* 17 */,
/* 18 */,
/* 19 */,
/* 20 */,
/* 21 */,
/* 22 */,
/* 23 */
/***/ function(module, exports, __webpack_require__) {

	__webpack_require__(24); // eslint-disable-line

	class OptionsPanel {
		constructor() {
			this._width = 0;
			this._height = 0;
			this._fps = 0;
			this._bitrate = 0;
			this._bgPage = chrome.extension.getBackgroundPage();
			this._extensionController = this._bgPage.getController();
			this._currentPreset = 0;

			this._presetOptionsDiv = null;
			this._inputElements = [];
			this._presetOptions = [];
		}

		prepareForm() {
			const currentSettings = this._extensionController.getCurrentSettings();
			this._presetOptionsDiv = document.getElementById('presetOptionList');
			this._inputElements = document.getElementsByTagName('input');
			this._presetOptions = this._presetOptionsDiv.children;
			this._width = currentSettings.width;
			this._height = currentSettings.height;
			this._fps = currentSettings.fps;
			this._bitrate = currentSettings.bitrate;
			this._currentPreset = currentSettings.presetOption;
			this._applyButton = document.getElementById('applySettingsButton');

			if (this._currentPreset !== 0) {
				this._setPresetValues(this._currentPreset, false);
			} else {
				this._setInputValues(this._height, this._fps, this._bitrate, false);
			}
			this._applyButton.className = 'button disabled';
		}

		_setInputValues(height, fps, bitrate, saveChanges = false) {
			for (const inputField of this._inputElements) {
				let newValue = 0;
				switch (inputField.id) {
					case 'qualitySlider':
						newValue = height;
						break;
					case 'fpsSlider':
						newValue = fps;
						break;
					case 'bpsSlider':
						newValue = bitrate;
						break;
					default:
						break;
				}
				this.setupInputField({ target: inputField }, newValue, saveChanges);
			}
		}

		_setPresetValues(presetOption, saveChanges = true) {
			this._currentPreset = Number(presetOption);
			this._applyButton.className = 'button';
			switch (this._currentPreset) {
				case 360:
					this._height = 360;
					this._fps = 10;
					this._bitrate = 500;
					break;
				case 480:
					this._height = 480;
					this._fps = 15;
					this._bitrate = 1000;
					break;
				case 720:
					this._height = 720;
					this._fps = 24;
					this._bitrate = 2000;
					break;
				default:
					break;
			}
			this._setInputValues(this._height, this._fps, this._bitrate, false);
			for (const preset of this._presetOptions) {
				if (Number(preset.getAttribute('data-value')) === this._currentPreset) {
					preset.className = 'selected';
				} else {
					preset.className = '';
				}
			}

			if (saveChanges) {
				this.saveCurrentOptionValues();
			}
		}

		_toggleInputListeners(enableListeners) {
			for (const inputField of this._inputElements) {
				const inputHandler = target => {
					this.handleInputFieldUpdate(target);
				};
				const valueChangeHandler = target => {
					this.handleInputFieldValueChange(target);
				};
				if (enableListeners) {
					inputField.addEventListener('input', inputHandler);
					inputField.addEventListener('change', valueChangeHandler);
				} else {
					inputField.removeEventListener('input', inputHandler);
					inputField.removeEventListener('change', valueChangeHandler);
				}
			}
			const presetClickHandler = target => {
				const clickSource = target.srcElement;
				this._setPresetValues(clickSource.dataset.value);
			};

			const applySettingsClickHandler = target => {
				const settings = {
					width: Math.floor(this._height * 1.77778),
					height: this._height,
					fps: this._fps,
					bitrate: this._bitrate,
					presetOption: this._currentPreset
				};

				this._extensionController.applySettings(settings);
				// restart the stream here
				// if the user changed the settings they were saved automatically so we dont need to save them again.
				window.close(); // close the popup so it seems like we did something
			};

			if (enableListeners) {
				this._presetOptionsDiv.addEventListener('click', presetClickHandler);
				this._applyButton.addEventListener('click', applySettingsClickHandler);
			} else {
				this._presetOptionsDiv.removeEventListener('click', presetClickHandler);
				this._applyButton.removeEventListener('click', applySettingsClickHandler);
			}
		}

		toggleForm(enableField = false) {
			for (const inputField of this._inputElements) {
				inputField.disabled = !enableField;
			}
			this._toggleInputListeners(enableField);
		}

		handleInputFieldValueChange(updatedInput) {
			const targetInput = updatedInput.target;
			const currentSettings = this._extensionController.getCurrentSettings();
			if (targetInput) {

				this._width = currentSettings.width;
				this._height = currentSettings.height;

				if (targetInput.id === 'qualitySlider') {
					this._width = Math.floor(targetInput.value * 1.77778);
					this._height = Number(targetInput.value);
				}

				this._fps = targetInput.id === 'fpsSlider' ? Number(targetInput.value) : currentSettings.fps;
				this._bitrate = targetInput.id === 'bpsSlider' ? Number(targetInput.value) : currentSettings.bitrate;
				this.saveCurrentOptionValues();
				this._applyButton.className = 'button';
			}
		}

		handleInputFieldUpdate(updatedInput) {
			const targetInput = updatedInput.target;
			if (targetInput) {

				const afterelem = window.getComputedStyle(targetInput, ':after');
				const newLeft = (targetInput.value - targetInput.min) / (targetInput.max - targetInput.min) * 100;
				let extraPadding = Number(afterelem.width.replace('px', '')) / 2 + Number(afterelem.paddingLeft.replace('px', ''));

				if (newLeft === 0) {
					extraPadding = 0;
				} else if (newLeft >= 95) {
					extraPadding = Number(afterelem.width.replace('px', '')) + Number(afterelem.paddingRight.replace('px', ''));
				}

				targetInput.setAttribute('data-tooltip', `${Number(targetInput.value) !== 25 ? targetInput.value : 24}${targetInput.getAttribute('data-abbreviation')}`);
				document.styleSheets[0].addRule(`#${targetInput.id}:after`, `left: calc(${newLeft}% - ${extraPadding}px)`);
				if (this._currentPreset !== 0) {
					this._currentPreset = 0;
					this._setPresetValues(this._currentPreset);
				}
			}
		}

		setupInputField(updatedInput, newValue, saveChanges = true) {
			const targetInput = updatedInput.target;

			if (targetInput) {
				targetInput.value = newValue;
				targetInput.setAttribute('data-tooltip', `${Number(targetInput.value) !== 25 ? targetInput.value : 24}${targetInput.getAttribute('data-abbreviation')}`);
				const afterelem = window.getComputedStyle(targetInput, ':after');
				const newLeft = (targetInput.value - targetInput.min) / (targetInput.max - targetInput.min) * 100;
				let extraPadding = Number(afterelem.width.replace('px', '')) / 2 + Number(afterelem.paddingLeft.replace('px', ''));

				if (newLeft === 0) {
					extraPadding = 0;
				} else if (newLeft >= 95) {
					extraPadding = Number(afterelem.width.replace('px', '')) + Number(afterelem.paddingRight.replace('px', ''));
				}

				document.styleSheets[0].addRule(`#${targetInput.id}:after`, `left: calc(${newLeft}% - ${extraPadding}px)`);

				if (saveChanges) {
					this.saveCurrentOptionValues();
				}
			}
		}

		saveCurrentOptionValues() {
			const newSettings = {
				width: Math.floor(this._height * 1.77778),
				height: this._height,
				fps: this._fps,
				bitrate: this._bitrate,
				presetOption: this._currentPreset
			};
			//save only when the settings are applied
			this._extensionController.saveSettings(newSettings);
		}
	}

	module.exports = OptionsPanel;

/***/ },
/* 24 */
/***/ function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag

	// load the styles
	var content = __webpack_require__(25);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(12)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!./../../node_modules/css-loader/index.js!./../../node_modules/less-loader/index.js?root=..!./optionsStyle.less", function() {
				var newContent = require("!!./../../node_modules/css-loader/index.js!./../../node_modules/less-loader/index.js?root=..!./optionsStyle.less");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ },
/* 25 */
/***/ function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(6)();
	// imports


	// module
	exports.push([module.id, "@font-face {\n  font-family: \"Source Sans\";\n  src: url(" + __webpack_require__(26) + ") format(\"truetype\");\n  font-weight: 300;\n  font-style: normal;\n}\n@font-face {\n  font-family: \"Source Sans\";\n  src: url(" + __webpack_require__(27) + ") format(\"truetype\");\n  font-weight: 400;\n  font-style: normal;\n}\n@font-face {\n  font-family: \"Source Sans\";\n  src: url(" + __webpack_require__(28) + ") format(\"truetype\");\n  font-weight: 600;\n  font-style: normal;\n}\n* {\n  padding: 0px;\n  margin: 0px;\n  font-family: \"Source Sans\", \"Helvetica Neue\", Helvetica, Arial, sans-serif;\n  font-weight: 400;\n}\nh1,\nh2 {\n  font-size: 16px;\n  padding: 20px 10px 0px 10px;\n}\np {\n  padding: 14px;\n  text-align: center;\n}\nbody {\n  width: 250px;\n  height: 420px;\n  font-size: 16px;\n  color: #001A3A;\n}\n.link {\n  color: #ff6600;\n  text-decoration: none;\n  cursor: pointer;\n}\n.link:hover {\n  color: #ff7316;\n}\n.button {\n  border-radius: 5px;\n  background-color: #ff6600;\n  color: white;\n  border: 0px;\n  font-size: 16px;\n  cursor: pointer;\n  width: 50%;\n  margin: 0px auto;\n  text-align: center;\n  padding: 5px 20px;\n}\n.button.disabled {\n  background-color: #d8d8d8;\n}\n.button:hover {\n  background-color: #ff7316;\n}\n.button:active {\n  background-color: #e1581a;\n}\n.optionsBody {\n  position: relative;\n  width: 400px;\n  height: 395px;\n}\n.optionsSliderContainer {\n  overflow-x: auto;\n}\n.optionsContainer {\n  margin-top: 10px;\n  position: relative;\n  width: 250px;\n  left: 75px;\n}\n.optionsContent {\n  margin: 10px;\n  position: relative;\n  font-size: 12px;\n}\n.optionsContent #presetOptionList {\n  width: 40%;\n}\n.optionsContent .selected {\n  background: transparent no-repeat url(" + __webpack_require__(29) + ") 4px center;\n}\n.optionsContent label {\n  padding: 0px 10px;\n}\n.optionsContent ol {\n  padding-left: 20px;\n  cursor: pointer;\n}\n.optionsContent ol:hover {\n  background-color: #E5E8EB;\n}\n.optionsContent sup {\n  font-size: 10px;\n  color: #ff6600;\n  font-family: \"Source Sans\", \"Helvetica Neue\", Helvetica, Arial, sans-serif;\n  font-weight: 600;\n  text-transform: uppercase;\n  line-height: 0px;\n  font-weight: 400;\n}\n.optionsContent h1 {\n  padding: 10px 0px;\n  font-size: 14px;\n}\n.optionsContent h1:first-child {\n  padding: 0px;\n}\n#optionsBackLink {\n  padding: 10px 0px 0px 0px;\n  font-size: 12px;\n}\n.backIcon {\n  background-image: url(" + __webpack_require__(30) + ");\n  background-size: cover;\n  width: 16px;\n  height: 10px;\n  display: inline-block;\n  transform: rotate(-90deg);\n}\n#applySettingsButton {\n  margin-bottom: 10px;\n}\n.extraText {\n  padding: 10px;\n  background-color: rgba(216, 216, 216, 0.3);\n  text-align: center;\n  font-size: 14px;\n  margin-bottom: 15px;\n}\ninput[type=range] {\n  -webkit-appearance: none;\n  width: 100%;\n  padding: 20px 10px 5px 10px;\n}\ninput[type=range]:focus {\n  outline: none;\n}\ninput[type=range]:disabled {\n  cursor: default;\n}\ninput[type=range]::-webkit-slider-runnable-track {\n  width: 100%;\n  height: 2px;\n  cursor: pointer;\n  background: #d8d8d8;\n  border-radius: 0px;\n  border: 0px solid #d8d8d8;\n}\ninput[type=range]:focus::-webkit-slider-runnable-track {\n  background: #d8d8d8;\n}\ninput[type=range]:disabled::-webkit-slider-runnable-track {\n  background: #d8d8d8;\n}\ninput[type=range]::-webkit-slider-thumb {\n  border: 0px solid #ff6600;\n  height: 10px;\n  width: 10px;\n  border-radius: 50%;\n  background: #ff6600;\n  cursor: pointer;\n  -webkit-appearance: none;\n  margin-top: -3.6px;\n}\ninput[type=range]:hover::-webkit-slider-thumb {\n  background-color: #ff7316;\n  box-shadow: rgba(255, 182, 108, 0.72) 0px 0px 5px;\n}\ninput[type=range]:disabled::-webkit-slider-thumb {\n  background-color: #d8d8d8;\n}\ninput[type=range]:after {\n  position: absolute;\n  margin-top: -20px;\n  left: attr(data-left);\n  background-color: transparent;\n  border-radius: 3px;\n  content: attr(data-tooltip);\n  padding: 2px 0px;\n  z-index: 98;\n  font-size: 12px;\n  color: #BDBDBD;\n  text-align: center;\n  white-space: nowrap;\n  line-height: 100%;\n  opacity: 1;\n  transition: all 100ms ease-in-out;\n  min-width: 30px;\n}\nlabel:hover input[type=range]:after,\ninput[type=range]:disabled:after {\n  opacity: 1;\n}\n", ""]);

	// exports


/***/ },
/* 26 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/fonts/OpenSans-Light.ttf";

/***/ },
/* 27 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/fonts/OpenSans-Regular.ttf";

/***/ },
/* 28 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/fonts/OpenSans-Bold.ttf";

/***/ },
/* 29 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/images/check-mark-black.svg";

/***/ },
/* 30 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/images/up-arrow.svg";

/***/ },
/* 31 */
/***/ function(module, exports, __webpack_require__) {

	const OptionsPanel = __webpack_require__(23); // eslint-disable-line

	__webpack_require__(32); // eslint-disable-line

	const MainPanelStates = {
		startPanel: 'startPanel',
		tabListPanel: 'tabListPanel',
		stealRemotePanel: 'stealRemotePanel'
	};

	class RabbitPopup {
		constructor() {
			this._bgPage = null;
			this._extensionController = null;
			this._startButtonContainer = null;
			this._startButtonDiv = null;
			this._stealRemoteContainer = null;
			this._popupInitalized = false;
			this._tabListData = null;
			this._tabListDiv = null;
			this._footerButtonDiv = null;
			this._contentSliderDiv = null;
			this._activeFooterButton = 'homeButton';
			this._currentTab = null;

			// eslint-disable-next-line
			this._bgPage = chrome.extension.getBackgroundPage();
			if (this._bgPage) {
				this._extensionController = this._bgPage.getController();
			}
		}

		initalizePopup() {

			this._startButtonDiv = document.getElementById('startStreamButton');
			this._startButtonContainer = document.getElementById('startButtonContainer');
			this._tabListDiv = document.getElementById('tabListContainer');
			this._stealRemoteContainer = document.getElementById('stealRemoteContainer');
			this._tabListDivContent = document.getElementById('tabListingContent');
			this._footerButtonDiv = document.getElementById('footerButtons');
			this._contentSliderDiv = document.getElementById('slider');
			this._optionsPanel = new OptionsPanel();
			this._optionsPanel.prepareForm();

			chrome.tabs.query({ active: true, currentWindow: true }, activeTabs => {
				this.startListeners();

				this._currentTab = activeTabs[0];
				const activeRooms = this._extensionController._getActiveRoomsConnections();
				const streamingTabId = this._extensionController.getCapturedTabID();

				this._startButtonDiv.innerHTML = `${!this.isCurrentTabStreaming() ? 'Start' : 'Stop'} Sharing`;

				if (this._currentTab.url.indexOf('rabb.it') >= 0) {

					let showStealRemote = false;
					if (streamingTabId) {
						for (const room of activeRooms) {
							const roomData = room.getRoomData();
							if (roomData.tabId === this._currentTab.id && roomData.hasScreencast && !roomData.hasRemote) {
								showStealRemote = roomData.hasScreencast;
							}
						}
					}

					if (showStealRemote) {
						this.setMainPanelState(MainPanelStates.stealRemotePanel);
					} else {
						this.setMainPanelState(MainPanelStates.tabListPanel);
					}
				} else {
					this.setMainPanelState(MainPanelStates.startPanel);
				}
			});

			this._popupInitalized = true;
		}

		onMessage(connection, msg) {
			// console.error(connection, msg);
		}

		setMainPanelState(newState = MainPanelStates.startPanel) {

			switch (newState) {
				default:
				case MainPanelStates.startPanel:
					this.showStartPanel();
					break;

				case MainPanelStates.tabListPanel:
					this.showTabListing();
					break;

				case MainPanelStates.stealRemotePanel:
					this.showStealRemotePanel();
					break;
			}
		}

		showStartPanel() {
			const activeRooms = this._extensionController._getActiveRoomsConnections();
			const startPanel = document.getElementById('startPanel');
			const roomsPanel = document.getElementById('roomsPanel');

			if (this.isCurrentTabStreaming()) {
				this._startButtonDiv.addEventListener('click', this.onStopClicked.bind(this));
			} else {
				this._startButtonDiv.addEventListener('click', this.onStartClicked.bind(this));
			}

			startPanel.style.display = activeRooms.length > 1 ? 'none' : 'inline-block';
			roomsPanel.style.display = activeRooms.length > 1 ? 'inline-block' : 'none';

			if (activeRooms.length === 1) {
				const header = document.getElementById('startScreenHeader');
				const activeRoom = activeRooms[0];
				const roomData = activeRoom.getRoomData();

				header.innerHTML = `Share this tab in ${roomData.roomName}.`;
			} else if (activeRooms.length > 1) {
				const roomListing = document.getElementById('activeRoomsList');
				while (roomListing.children.length > 0) {
					roomListing.removeChild(roomListing.children[0]);
				}
				let roomIndex = 0;
				for (const room of activeRooms) {

					const roomData = room.getRoomData();
					const rowDiv = document.createElement('div');
					const rowIcon = document.createElement('div');
					const rowLabel = document.createElement('div');

					rowDiv.className = 'tabRow clickable';
					rowDiv.id = roomIndex;

					rowIcon.className = 'rowIcon';
					rowIcon.id = roomIndex;
					rowIcon.style.backgroundImage = `url(${roomData.roomCreatorAvatar})`;
					rowDiv.appendChild(rowIcon);

					rowLabel.innerHTML = roomData.roomName;
					rowLabel.id = roomIndex;
					rowLabel.className = 'rowLabel';
					rowDiv.appendChild(rowLabel);

					rowDiv.onclick = clickEvent => {
						const roomId = Number(clickEvent.target.id);
						this._extensionController.setupTabCapture(roomId);
					};

					roomListing.appendChild(rowDiv);
					roomIndex++;
				}
			}

			this._startButtonContainer.style.display = 'block';
			this._stealRemoteContainer.style.display = 'none';
			this._tabListDiv.style.display = 'none';
		}

		showStealRemotePanel() {
			const activeRooms = this._extensionController._getActiveRoomsConnections();
			const activeRoom = activeRooms[0];
			const roomData = activeRoom.getRoomData();
			const header = document.getElementById('stealRemoteHeader');
			if (roomData.controllerUsername !== '') {
				header.innerHTML = `${roomData.controllerUsername} has the remote.`;
			} else {
				header.innerHTML = `Guest has the remote for ${roomData.roomName}.`;
			}

			const stealRemoteButton = document.getElementById('stealRemoteButton');
			if (roomData.canStealRemote) {
				stealRemoteButton.style.display = 'block';
				stealRemoteButton.addEventListener('click', () => {
					this._extensionController.stealRemote(activeRoom);
					window.close();
				});
			} else {
				stealRemoteButton.style.display = 'none';
			}

			this._startButtonContainer.style.display = 'none';
			this._stealRemoteContainer.style.display = 'block';
			this._tabListDiv.style.display = 'none';
		}

		startListeners() {
			this._footerButtonDiv.addEventListener('click', this.onFooterButtonClicked.bind(this));

			// popup embedded links
			const optionsLink = document.getElementById('optionsLink');
			optionsLink.onclick = () => {
				this._activeFooterButton = 'settingsButton';
				this._optionsPanel.toggleForm(true);
				this._slideToContent();
				this._updateFooterButtons();
			};

			const feedbackLink = document.getElementById('sendFeedbackLink');
			feedbackLink.onclick = () => {
				chrome.tabs.query({ active: true, currentWindow: true }, activeTabs => {
					const currentTab = activeTabs[0];
					if (currentTab.url.indexOf('rabb.it') >= 0) {
						this._extensionController._showFeedbackPopup();
					} else {
						chrome.tabs.create({ url: 'https://www.rabb.it/contact-us' });
					}
				});
			};

			const faqLink = document.getElementById('faqLink');
			faqLink.onclick = () => {
				chrome.tabs.create({ url: 'http://rabb.it/help' });
			};

			const optBackLink = document.getElementById('optionsBackLink');
			optBackLink.onclick = () => {
				this._activeFooterButton = 'homeButton';
				this._optionsPanel.toggleForm(false);
				this._slideToContent();
				this._updateFooterButtons();
			};
		}

		isTabStreamIdle() {
			return this._extensionController.isTabStreamIdle();
		}

		isCurrentTabStreaming() {
			return this._extensionController.getCapturedTabID() === this._currentTab.id;
		}

		onStartClicked() {
			this._extensionController.setupTabCapture();
			window.close();
		}

		onStopClicked() {
			this._extensionController.stopTabCapture();
			window.close();
		}

		onFooterButtonClicked(mouseEvent) {
			const targetDiv = mouseEvent.target;

			if (targetDiv.id && targetDiv.id !== this._activeFooterButton) {
				this._activeFooterButton = targetDiv.id;
				this._optionsPanel.toggleForm(this._activeFooterButton === 'settingsButton');
				this._slideToContent();
				this._updateFooterButtons();
			}
		}

		_slideToContent() {
			switch (this._activeFooterButton) {
				default:
					break;
				case 'homeButton':
					this._contentSliderDiv.style.transform = 'translateX(0px)';
					break;
				case 'settingsButton':
					this._contentSliderDiv.style.transform = 'translateX(-250px)';
					break;
			}
		}

		_updateFooterButtons() {
			for (const buttonDiv of this._footerButtonDiv.children) {
				let currentClassname = buttonDiv.className;
				if (currentClassname.indexOf(this._activeFooterButton) >= 0) {
					currentClassname = currentClassname.replace('-off', '-on');
				} else {
					currentClassname = currentClassname.replace('-on', '-off');
				}
				buttonDiv.className = currentClassname;
			}
		}

		clearTabListing() {
			while (this._tabListDivContent.children.length > 0) {
				this._tabListDivContent.removeChild(this._tabListDivContent.children[0]);
			}
		}

		createTabRow(tab) {
			const rowDiv = document.createElement('div');
			const rowIcon = document.createElement('div');
			const rowLabel = document.createElement('div');
			const isTabCaptured = tab.id === this._extensionController.getCapturedTabID();
			const tabId = tab.id;
			const windowId = tab.windowId;

			rowIcon.className = `rowIcon${isTabCaptured ? ' captured' : ''}`;
			rowIcon.setAttribute('data-tabid', tabId);
			rowIcon.setAttribute('data-windowId', windowId);
			if (tab.favIconUrl && tab.favIconUrl.indexOf('chrome://') < 0 && tab.id !== -1) {
				rowIcon.style.backgroundImage = `url(${tab.favIconUrl})`;
			} else if (tab.id === -1) {
				rowIcon.style.backgroundImage = 'url(/images/new-tab-icon.svg)';
			}
			rowDiv.appendChild(rowIcon);

			rowLabel.innerHTML = tab.title;
			rowLabel.setAttribute('data-tabid', tabId);
			rowLabel.setAttribute('data-windowId', windowId);
			rowLabel.className = 'rowLabel';
			rowDiv.appendChild(rowLabel);

			rowDiv.className = 'tabRow clickable';
			rowDiv.setAttribute('data-tabid', tabId);
			rowDiv.setAttribute('data-windowId', windowId);

			rowDiv.onclick = clickEvent => {
				const tabDataset = clickEvent.target.dataset;
				const tabID = Number(tabDataset.tabid);
				const windowID = Number(tabDataset.windowid);
				if (tabID === -1) {
					chrome.tabs.create({});
				} else {
					chrome.windows.update(windowID, { focused: true });
					chrome.tabs.update(tabID, { active: true });
				}
			};

			return rowDiv;
		}

		showTabListing() {

			this.clearTabListing();

			chrome.tabs.query({}, tabs => {
				this._tabListData = tabs;
				this._tabListData.push({
					id: -1,
					title: 'Open a new tab to share in this room',
					url: 'new tab'
				});
				if (this._tabListDivContent !== null && this._tabListData !== null && this._tabListData.length !== 0) {
					this._startButtonContainer.style.display = 'none';
					this._stealRemoteContainer.style.display = 'none';
					this._tabListDiv.style.display = 'block';
					for (const tab of this._tabListData) {
						if (tab) {
							if (tab.url.indexOf('rabb.it') === -1 || !tab.url) {
								this._tabListDivContent.appendChild(this.createTabRow(tab));
							}
						}
					}
				} else {
					this._startButtonContainer.style.display = 'block';
					this._stealRemoteContainer.style.display = 'none';
					this._tabListDiv.style.display = 'none';
				}

				if (!this.isTabStreamIdle()) {
					const stopButtonRowDiv = document.createElement('div');
					stopButtonRowDiv.className = 'stopButtonRow';
					const stopButtonDiv = document.createElement('div');
					stopButtonDiv.className = 'stopButton button';
					stopButtonDiv.innerHTML = 'Stop Sharing';
					stopButtonDiv.addEventListener('click', () => {
						this._extensionController.stopTabCapture();
						this.showTabListing();
					});

					stopButtonRowDiv.appendChild(stopButtonDiv);
					this._tabListDivContent.appendChild(stopButtonRowDiv);
				}
			});
		}

	}

	module.exports = RabbitPopup;

/***/ },
/* 32 */
/***/ function(module, exports, __webpack_require__) {

	// style-loader: Adds some css to the DOM by adding a <style> tag

	// load the styles
	var content = __webpack_require__(33);
	if(typeof content === 'string') content = [[module.id, content, '']];
	// add the styles to the DOM
	var update = __webpack_require__(12)(content, {});
	if(content.locals) module.exports = content.locals;
	// Hot Module Replacement
	if(false) {
		// When the styles change, update the <style> tags
		if(!content.locals) {
			module.hot.accept("!!./../../node_modules/css-loader/index.js!./../../node_modules/less-loader/index.js?root=..!./popupStyle.less", function() {
				var newContent = require("!!./../../node_modules/css-loader/index.js!./../../node_modules/less-loader/index.js?root=..!./popupStyle.less");
				if(typeof newContent === 'string') newContent = [[module.id, newContent, '']];
				update(newContent);
			});
		}
		// When the module is disposed, remove the <style> tags
		module.hot.dispose(function() { update(); });
	}

/***/ },
/* 33 */
/***/ function(module, exports, __webpack_require__) {

	exports = module.exports = __webpack_require__(6)();
	// imports


	// module
	exports.push([module.id, "@font-face {\n  font-family: \"Source Sans\";\n  src: url(" + __webpack_require__(26) + ") format(\"truetype\");\n  font-weight: 300;\n  font-style: normal;\n}\n@font-face {\n  font-family: \"Source Sans\";\n  src: url(" + __webpack_require__(27) + ") format(\"truetype\");\n  font-weight: 400;\n  font-style: normal;\n}\n@font-face {\n  font-family: \"Source Sans\";\n  src: url(" + __webpack_require__(28) + ") format(\"truetype\");\n  font-weight: 600;\n  font-style: normal;\n}\n* {\n  padding: 0px;\n  margin: 0px;\n  font-family: \"Source Sans\", \"Helvetica Neue\", Helvetica, Arial, sans-serif;\n  font-weight: 400;\n}\nh1,\nh2 {\n  font-size: 16px;\n  padding: 20px 10px 0px 10px;\n}\np {\n  padding: 14px;\n  text-align: center;\n}\nbody {\n  width: 250px;\n  height: 420px;\n  font-size: 16px;\n  color: #001A3A;\n}\n.link {\n  color: #ff6600;\n  text-decoration: none;\n  cursor: pointer;\n}\n.link:hover {\n  color: #ff7316;\n}\n.button {\n  border-radius: 5px;\n  background-color: #ff6600;\n  color: white;\n  border: 0px;\n  font-size: 16px;\n  cursor: pointer;\n  width: 50%;\n  margin: 0px auto;\n  text-align: center;\n  padding: 5px 20px;\n}\n.button.disabled {\n  background-color: #d8d8d8;\n}\n.button:hover {\n  background-color: #ff7316;\n}\n.button:active {\n  background-color: #e1581a;\n}\n.popupMain {\n  display: flex;\n  flex-direction: column;\n  width: 250px;\n  height: 420px;\n}\n.popupHeader {\n  height: 45px;\n  border-bottom: solid 1px #d8d8d8;\n  background-image: url(" + __webpack_require__(34) + ");\n  background-position: center center;\n  background-repeat: no-repeat;\n}\n.popupContent {\n  height: 336px;\n  width: 250px;\n  padding: 0px;\n  position: relative;\n  overflow: hidden;\n}\n.contentSlider {\n  position: absolute;\n  left: 0px;\n  top: 0px;\n  width: 1000px;\n  height: 311px;\n  display: flex;\n  flex-direction: row;\n  transition: all 150ms ease-in-out;\n}\n.startButtonContainer,\n.tabListContainer,\n.optionsSliderContainer,\n.stealRemoteContainer {\n  width: 250px;\n  height: 336px;\n  position: relative;\n}\n.startButtonContainer h1 {\n  text-align: center;\n  padding: 50px 10px 30px 10px;\n}\n.startButtonContainer p {\n  padding: 10px 20px 50px 15px;\n}\n.tabListContainer,\n.roomsList {\n  overflow-x: auto;\n}\n.tabListContainer p,\n.roomsList p {\n  font-size: 18px;\n  padding: 5px;\n  text-align: left;\n}\n.tabListContainer .tabRow,\n.roomsList .tabRow {\n  height: 46px;\n  display: flex;\n  flex-direction: row;\n  border-bottom: solid 1px #d8d8d8;\n  cursor: pointer;\n}\n.tabListContainer .tabRow .rowIcon,\n.roomsList .tabRow .rowIcon {\n  width: 40px;\n  height: 46px;\n  background-image: url(" + __webpack_require__(35) + ");\n  background-size: 30px;\n  background-repeat: no-repeat;\n  background-position: center center;\n  position: relative;\n}\n.tabListContainer .tabRow .rowIcon.captured:after,\n.roomsList .tabRow .rowIcon.captured:after {\n  position: absolute;\n  width: 16px;\n  height: 16px;\n  background-image: url(" + __webpack_require__(36) + ");\n  left: 27px;\n  top: 27px;\n  content: \"\";\n}\n.tabListContainer .tabRow .rowLabel,\n.roomsList .tabRow .rowLabel {\n  overflow: hidden;\n  display: -webkit-box;\n  -webkit-line-clamp: 2;\n  -webkit-box-orient: vertical;\n  padding-left: 5px;\n  font-size: 14px;\n  width: 190px;\n  height: 40px;\n  margin-top: 4px;\n}\n.tabListContainer .stopButtonRow,\n.roomsList .stopButtonRow {\n  height: 50px;\n  width: 250px;\n}\n.tabListContainer .stopButtonRow .stopButton,\n.roomsList .stopButtonRow .stopButton {\n  background-color: #d8d8d8;\n  position: relative;\n  left: auto;\n  height: 32px;\n  line-height: 32px;\n  width: 55%;\n  margin: 10px auto;\n  text-align: center;\n}\n.tabListContainer .stopButtonRow .stopButton:hover,\n.roomsList .stopButtonRow .stopButton:hover {\n  background-color: #ff6600;\n}\n.tabListContainer .tabRow:last-child,\n.roomsList .tabRow:last-child {\n  border-bottom: solid 0px #ffffff;\n}\n.tabListContainer .tabRow:hover.clickable,\n.roomsList .tabRow:hover.clickable {\n  background-color: #E5E8EB;\n}\n.roomsList .tabRow {\n  border-bottom: 0px;\n}\n.roomsList .tabRow .rowIcon {\n  overflow: hidden;\n  border-radius: 50%;\n  width: 40px;\n  height: 40px;\n  background-size: contain;\n  margin: 3px 0px 0px 12px;\n}\n.roomsList .tabRow .rowLabel {\n  -webkit-line-clamp: 1;\n  line-height: 40px;\n  font-size: 14px;\n}\n.stealRemoteContainer h1 {\n  padding: 35px;\n  text-align: center;\n}\n.stealRemoteContainer .stealIcon {\n  width: 45px;\n  height: 45px;\n  background-image: url(" + __webpack_require__(37) + ");\n  background-size: cover;\n  margin: 24px auto 0px auto;\n}\n.popupFooter {\n  border-top: solid 1px #d8d8d8;\n  height: 39px;\n  display: flex;\n  flex-direction: row;\n}\n.footerButtons {\n  width: 50%;\n  height: 39px;\n}\n.homeButton-on {\n  background: no-repeat url(" + __webpack_require__(38) + ") center center;\n}\n.homeButton-on#home-button-svg polygon {\n  stroke-width: 5px;\n}\n.homeButton-off {\n  background: no-repeat url(" + __webpack_require__(39) + ") center center;\n  cursor: pointer;\n}\n.homeButton-off:hover {\n  background: no-repeat url(" + __webpack_require__(38) + ") center center;\n}\n.settingsButton-on {\n  background: no-repeat url(" + __webpack_require__(40) + ") center center;\n}\n.settingsButton-off {\n  background: no-repeat url(" + __webpack_require__(41) + ") center center;\n  cursor: pointer;\n}\n.settingsButton-off:hover {\n  background: no-repeat url(" + __webpack_require__(40) + ") center center;\n}\n.newTabIcon {\n  background: no-repeat url(" + __webpack_require__(42) + ") center center;\n}\n::-webkit-scrollbar {\n  width: 8px;\n  height: 8px;\n}\n::-webkit-scrollbar-button {\n  width: 8px;\n  height: 8px;\n}\n::-webkit-scrollbar-thumb {\n  background: #d8d8d8;\n  border: 0px none #ffffff;\n  border-radius: 4px;\n}\n::-webkit-scrollbar-track {\n  background: #ffffff;\n  border: 0px none #ffffff;\n  border-radius: 10px;\n}\n::-webkit-scrollbar-corner {\n  background: transparent;\n}\n", ""]);

	// exports


/***/ },
/* 34 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/images/rabbit-header-text.svg";

/***/ },
/* 35 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/images/default-tab-icon.svg";

/***/ },
/* 36 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/images/casting-icon.svg";

/***/ },
/* 37 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/images/steal-remote-icon.svg";

/***/ },
/* 38 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/images/home-button-on.svg";

/***/ },
/* 39 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/images/home-button-off.svg";

/***/ },
/* 40 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/images/settings-button-on.svg";

/***/ },
/* 41 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/images/settings-button-off.svg";

/***/ },
/* 42 */
/***/ function(module, exports, __webpack_require__) {

	module.exports = __webpack_require__.p + "/images/new-tab-icon.svg";

/***/ }
/******/ ]);