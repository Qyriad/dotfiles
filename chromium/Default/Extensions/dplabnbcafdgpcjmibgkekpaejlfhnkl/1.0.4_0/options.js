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

	const OptionsPanel = __webpack_require__(23); // eslint-disable-line import/no-unresolved

	const _optionsPanel = new OptionsPanel();
	_optionsPanel.prepareForm();
	_optionsPanel.toggleForm(true);

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

/***/ }
/******/ ]);