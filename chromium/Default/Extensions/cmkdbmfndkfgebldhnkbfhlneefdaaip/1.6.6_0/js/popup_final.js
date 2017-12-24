var currentHostName = '',
	detectedApps = {};
(function() {
	$(document).ready(function() {
		var d = document;
		var techInfoEl = $('#tech-info');
		var evenEl = $('#even');
		var oddEl = $('#odd');
		var siteEl = $(".current-site-name");
		var popup = {
			self: '',
			init: function() {
				self = popup;
				this.setEvents();
			},
			tabQuery: function(callback) {
				try {
					browser.tabs.query({
						active: true,
						currentWindow: true
					}).then(callback);
				} catch (e) {
					console.log(e);
				}
			},
			setEvents: function() {
				var sendMessage = function(tabs) {
					BROWSER.runtime.sendMessage({
						id: GET_DETECTED_APPS,
						tab: tabs[0]
					}, function(res) {
						if (typeof res != "undefined" && typeof res.tabTechs != "undefined" && typeof res.tabTechs.response != "undefined") {
							self.processResponse(res);
						} else {
							self.getAppsByDomainName(tabs);
						}
					});
				};

				self.tabQuery(sendMessage);

			},
			getAppsByDomainName: function(tabs) {
				try {
					var sendMessage = function(tabs) {
						BROWSER.runtime.sendMessage({
							id: GET_HOST_NAME,
							tab: tabs[0]
						}, function(res) {

							if (typeof res.hostname != "undefined" && res.hostname != null) {
								if (res.hostname == "newtab") {
									self.showContent();
								} else if (invalidDomains.indexOf(res.hostname) >= 0) {
									self.showInvalidAddressContent();
								} else {
									res.type = "ajax";
									if (typeof res.subdomain != "undefined") res.hostname = res.rawhostname;
									self.getAppsFromHost(GET_SITE_APPS, res.hostname, res);
								}
							} else self.showContent();
						});
					};
				} catch (e) {

				}
				self.tabQuery(sendMessage);
			},
			getAppsFromHost: function(serverUrl, hostname, data) {
				try {
					var xmlhttp = new XMLHttpRequest();

					xmlhttp.open('POST', serverUrl, true);

					xmlhttp.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

					xmlhttp.onreadystatechange = function(e) {
						if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
							try {
								var res = JSON.parse(xmlhttp.responseText) || {};
								if (typeof res.apps != "undefined") {
									var response = {
										"response": JSON.parse(res.apps) || {},
										hostname: hostname
									}
									var data = {
										tabTechs: response
									}
									self.processResponse(data);
								} else {
									self.getSiteData();
								}
							} catch (e) {
								console.log(e);
								self.showContent();
							}
						}
					};
					xmlhttp.send('data=' + encodeURIComponent(JSON.stringify(data)));
				} catch (e) {
					self.showContent();
				}
			},
			getSiteData: function() {
				try {
					var sendMessage = function(tabs) {
						BROWSER.runtime.sendMessage({
							id: GET_SITE_DATA,
							tab: tabs[0]
						}, function(res) {
							if (typeof res.data != "undefined" && res.data != null) {
								self.analyseSiteData(res.data);
							} else {
								self.setNoAppsFoundText();
							}
						});
					};
				} catch (e) {

				}
				self.tabQuery(sendMessage);
			},
			analyseSiteData: function(data) {
				try {
					if (typeof data.hostname != "undefined") currentHostName = data.hostname;
					if (typeof data.subdomain != "undefined") {
						currentHostName = data.rawhostname;
					}

					var xmlhttp = new XMLHttpRequest();

					xmlhttp.open('POST', GET_SITE_APPS_BY_DATA, true);

					xmlhttp.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');

					xmlhttp.onreadystatechange = function(e) {
						if (xmlhttp.readyState == 4 && xmlhttp.status == 200) {
							try {
								var response = xmlhttp.responseText,
									res = {};
								if (typeof response != "object") var res = JSON.parse(response) || {};
								else res = response;
								if (typeof res.apps != "undefined") {
									var newFormat = {
										"response": JSON.parse(res.apps) || {},
										hostname: data.hostname
									}
									Object.keys(data).forEach(function(key) {
										newFormat[key] = data[key];
									});
									if (typeof data.subdomain != "undefined") newFormat.hostname = data.rawhostname;
									var finalData = {
										tabTechs: newFormat
									}
									self.processResponse(finalData);
								} else {
									self.setNoAppsFoundText(data);
								}
							} catch (e) {
								console.log(e);
								self.setNoAppsFoundText(data);
							}
						}
					};
					xmlhttp.send('data=' + encodeURIComponent(JSON.stringify(data)));
				} catch (e) {
					console.log(e);
					self.showContent();
				}
			},
			setNoAppsFoundText: function(data) {

				try {
					self.removeAppsDiv();
					$('.current-app-info').addClass("newtab-text");
					$('.current-app-info').text(NO_APPS_FOUND);
					$('.user-follow, .share-url').removeClass("active");
					var response = {
						hostname: data.hostname
					}
					var newData = {
						tabTechs: response
					}
					self.processResponse(newData);
				} catch (e) {
					console.log(e);
				}
			},
			processResponse: function(res) {
				try {
					currentHostName = self.getCurrentHostName(res);

					if (currentHostName.length > 24) currentHostName = currentHostName.substring(0, 21) + "..";
					$(siteEl).text(currentHostName);
					popup.displayApps(res, self);
					setTimeout(function() {
						self.showContent();
					}, 500);

				} catch (e) {
					console.log(e);
				}
			},
			ucFirstAllWords: function(str) {
				var pieces = str.split(" ");
				for (var i = 0; i < pieces.length; i++) {
					var j = pieces[i].charAt(0).toUpperCase();
					pieces[i] = j + pieces[i].substr(1).toLowerCase();
				}
				return pieces.join(" ");
			},
			getCurrentHostName: function(data) {
				try {
					if (typeof data.rawhostname != "undefined") return data.rawhostname;
					else if (typeof data.tabTechs.rawhostname != "undefined") return data.tabTechs.rawhostname;
					else if (typeof data.hostname != "undefined") return data.hostname;
					else if (typeof data.tabTechs.hostname != "undefined") return data.tabTechs.hostname;
				} catch (e) {
					console.log(e);
				}
				return "";
			},
			showContent: function() {
				$('.image-loader').hide();
				$('.content').addClass("slideDown");
				$('.share-url-header-icon').attr("title", "Share what runs " + currentHostName);

				if (currentHostName.trim().length <= 0) {
					$('.user-follow, .share-url-header-icon').hide();
					$('.current-app-info').addClass("newtab-text");
					$('.current-app-info').text("Please enter a website on your browser address bar.");
				}
			},
			showInvalidAddressContent: function() {
				try {
					$('.image-loader').hide();
					$('.content').addClass("slideDown");
					$('.current-app-info').addClass("newtab-text invalid-domain");
					$('.current-app-info').text("Please enter a valid domain name or IP address on your browser address bar.");
					$('.user-follow, .share-url').removeClass("active")

				} catch (e) {}
			},
			displayApps: function(response, self) {
				try {
					detectedApps = response.tabTechs.response;
					var endDisplayFramework = {};
					var list = 0;
					for (var time in detectedApps) {
						var apps = detectedApps[time];

						Object.keys(apps).forEach(function(categoryName) {
							var el = oddEl;
							if (list % 2 == 0) el = evenEl;
							var categoryClass = self.getCategoryClass(categoryName);
							if (categoryClass == "javascriptframeworks") {
								endDisplayFramework[categoryName] = apps[categoryName];
								//continue;
								return true;
							}
							self.appendAppDiv(el, categoryName, apps[categoryName], categoryClass);
							list++;
						});
					}
					if (Object.keys(endDisplayFramework).length > 0) {
						var el = oddEl;
						if (list % 2 == 0) el = evenEl;
						Object.keys(endDisplayFramework).forEach(function(categoryName) {
							var categoryClass = self.getCategoryClass(categoryName);
							self.appendAppDiv(el, categoryName, endDisplayFramework[categoryName], categoryClass);
						});
					}

					if (typeof response.tabTechs.fontFamily != "undefined") {
						var fontFamily = response.tabTechs.fontFamily.replace(/"/g, '');
						var font = fontFamily.split(",")[0];
						font = self.ucFirstAllWords(font.replace(/[-_]/gi, ' ').toString());
						fontFamily = self.ucFirstAllWords(fontFamily.replace(/[-_]/gi, ' ').toString());
						fontFamily = fontFamily.split(',').join(', ');
						try {
							$(oddEl).append(
								$('<div>', {
									"class": "techs-list"
								})
								.append(
									$('<div>', {
										"class": "category-name"
									}).text("Font")
								)
								.append(
									$('<div>', {
										"class": "border"
									})
								)
								.append(
									$('<div>', {
										"class": "current-tech-info sub-element capitalize"
									})
									.append(
										$('<span>', {
											"class": "label label-default"
										}).text("Font")
									)
									.append(
										$('<span>', {
											"class": "themes-list"
										}).text(font)
									)
								)
								.append(
									$('<div>', {
										"class": "current-tech-info sub-element capitalize"
									})
									.append(
										$('<span>', {
											"class": "label label-default"
										}).text("Font Family")
									)
									.append(
										$('<span>', {
											"class": "themes-list"
										}).text(fontFamily)
									)
								)
							);

						} catch (e) {
							console.log(e);
						}
					} else if (list <= 0) {
						self.removeAppsDiv();
						$(techInfoEl).append(
							$('<div>', {
								"class": "techs-list text-center no-apps"
							})
							.append($('<div>', {
								"class": "category-name no-apps"
							})).text(NO_APPS_FOUND)
						);
					}

				} catch (e) {

				}
				self.showSubElement();
			},
			appendAppDiv: function(el, categoryName, appsArr, categoryClass) {
				$(el).append(
					$('<div>', {
						"class": "techs-list " + categoryClass
					})
					.append($('<div>', {
						"class": "category-name"
					}).text(categoryName))
					.append($('<div>', {
						"class": "border"
					}))
				);
				try {
					//var
					var arr = appsArr;
					var themes = '',
						plugins = '';
					var techListEl = '';
					var length = 0;
					var techsListArr = [],
						isWordPressDisabled = false;

					for (var i in arr) {
						length = arr.length;
						var techJson = arr[i];
						var imageUrl = DOMAIN_NAME + "imgs/" + techJson.icon;
						if (typeof techJson.parentElement == "undefined") {
							if (techJson.enabled == "false") {
								if (techJson.name.toLowerCase() == "wordpress") isWordPressDisabled = true;
								if (length <= 1) $(el).find('.' + categoryClass).remove();
								continue;
							} else {
								techsListArr.push(techJson.name);
							}
							var href = "#";
							if (typeof techJson.website != "undefined") href = techJson.website;
							var siteListUrl = "#";
							if (typeof techJson.siteListUrl != "undefined") {
								siteListUrl = techJson.siteListUrl;
							}
							var techName = techJson.name + " ";
							if (typeof techJson.version !== "undefined") techName += techJson.version;
							techListEl = $('<div>', {
								"class": "current-tech-info"
							}).append(
								$('<img>', {
									"class": "icon",
									"src": imageUrl
								})
							).append(
								$('<div>', {
									"class": "tech-name"
								}).text(techName)
							).append(
								$('<a>', {
									"href": siteListUrl,
									"target": "_blank",
									"class": "techs-list-url",
									"data-toggle": "tooltip",
									"data-placement": "bottom",
									"title": "Know More"
								})
								.append($('<img>', {
									"src": "images/details.png"
								}))
							).append(
								$('<a>', {
									"href": href,
									"target": "_blank",
									"class": "original-site",
									"data-toggle": "tooltip",
									"data-placement": "bottom",
									"title": "Website"
								})
								.append($('<img>', {
									"src": "images/link.png"
								}))
							);
						} else {
							if (typeof techJson.theme !== "undefined") themes += self.capitalizeFirstLetter(techJson.name) + ", ";
							if (typeof techJson.plugin !== "undefined") {
								plugins += self.capitalizeFirstLetter(techJson.name) + ", ";
							}
						}
						$(el).append($(techListEl));
					}
					if (techsListArr.length <= 0) {
						$(el).find('.' + categoryClass).remove();
					}
					if (!isWordPressDisabled) {
						if (themes.split(",").length > 1) {
							$(el).append(
								$('<div>', {
									"class": "current-tech-info sub-element"
								})
								.append(
									$('<span>', {
										"class": "label label-default"
									}).text("Theme")
								)
								.append(
									$('<span>', {
										"class": "themes-list break-word"
									}).text(self.removeLastComma(themes))
								)
							);
						}
						if (plugins.split(",").length > 1) {
							$(el).append(
								$('<div>', {
									"class": "current-tech-info sub-element"
								})
								.append(
									$('<span>', {
										"class": "label label-default"
									}).text("Plugins")
								)
								.append(
									$('<span>', {
										"class": "plugins-list break-word"
									}).text(self.removeLastComma(plugins))
								)
							);
						}
					}
				} catch (e) {
					console.log(e);
				}

			},
			getCategoryClass: function(categoryName) {
				try {
					return categoryName.replace(/[^0-9a-zA-Z]/gi, '').toLowerCase();
				} catch (e) {
					console.log(e);
				}
				return '';
			},
			removeAppsDiv: function() {
				try {
					$(oddEl).remove();
					$(evenEl).remove();
				} catch (e) {
					console.log(e);
				}
			},
			beautifyName: function(name) {
				try {
					return name.toLowerCase().replace(/ /g, '-').replace(/[^\w-]/g, '');
				} catch (e) {}
				return name;
			},
			capitalizeFirstLetter: function(str) {
				try {
					return str.replace(/\w\S*/g, function(txt) {
						return txt.charAt(0).toUpperCase() + txt.substr(1).toLowerCase();
					});
				} catch (e) {
					console.log(e);
				}
				return str;
			},
			removeLastComma: function(str) {
				try {
					return str.replace(/,\s*$/, "");
				} catch (e) {
					console.log(e);
				}
				return str;
			},
			getNoAppDetectedMsg: function() {
				return '<div class="empty">' + chrome.i18n.getMessage('noScriptsDetected') + '</div>';
			},
			getDefaultMsg: function() {
				return '<div class="empty">' + chrome.i18n.getMessage('defaultMsg') + '</div>';
			},
			showSubElement: function() {
				try {
					var techListArr = document.getElementsByClassName("techs-list");
					for (var i = 0; i < techListArr.length; i++) {
						techListArr[i].onclick = function() {
							var element = this.querySelectorAll('.sub-element');
							for (var j = 0; j < element.length; j++) {
								element[j].className += ' active';
							}
						}
					}
				} catch (e) {}
			},
			emptyScriptsListEl: function() {
				scriptsListEl.innerHTML = '';
			}
		}
		popup.init();
	});
}());