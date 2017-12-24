var ANALYSE_APPS = "analyseApps";
var KEY_DETAILS = "keyDetails";
var finalData = {};
var BROWSER = (chrome || browser);
(function() {
	var su = {
		finalHtml: '',
		globalVars: '',
		fontFamily: '',
		contentExceeded: false,
		init: function() {
			this.addEventListener();
			this.getAPIKey();
		},
		getAPIKey: function() {
			//console.log(location)
			if (location.hostname === "whatruns.com" || location.hostname === "localhost") {
				var pathname = location.pathname;
				if (pathname.indexOf("dashboard") !== -1 || pathname.indexOf("search") !== -1) {
					try {
						var apiKey = document.getElementById('wrs_api_key').value;
						var email = document.getElementById('wrs_email').value;
						if (apiKey.trim().length > 0 && email.trim().length > 0) {
							BROWSER.runtime.sendMessage({
								id: KEY_DETAILS,
								subject: {
									api_key: apiKey,
									email: email
								}
							});
						}
					} catch (e) {}
				}
			}
		},
		addEventListener: function() {
			var scriptEl, divEl, html = document.documentElement.outerHTML;
			try {
				divEl = document.createElement('div');
				divEl.setAttribute('id', 'divScriptsUsed');
				divEl.setAttribute('style', 'display: none');

				scriptEl = document.createElement('script');

				scriptEl.setAttribute('id', 'globalVarsDetection');
				scriptEl.setAttribute('src', chrome.extension.getURL('js/wrs_env.js'));

				divEl.addEventListener('globalVarsEvent', (function(event) {
					var jsonStr = event.target.childNodes[0].nodeValue;
					try {
						var jsonObj = JSON.parse(jsonStr);
						globalVars = jsonObj.environmentVars;
						fontFamily = jsonObj.fontFamily;
					} catch (e) {
						console.log(e);
					}
					document.documentElement.removeChild(divEl);
					document.documentElement.removeChild(scriptEl);

					var finalData = {
						html: html,
						globalVars: JSON.stringify(globalVars),
						fontFamily: fontFamily,
						href: location.href
					}
					BROWSER.runtime.sendMessage({
						id: ANALYSE_APPS,
						subject: finalData
					});

				}), true);

				document.documentElement.appendChild(divEl);
				document.documentElement.appendChild(scriptEl);

			} catch (e) {
				console.log(e);
			}
		}
	}

	su.init();

}());
