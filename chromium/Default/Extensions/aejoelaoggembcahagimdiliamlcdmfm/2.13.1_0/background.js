restoreLastSessionTabs();

var payloadStore = {};

// Used in ChromeAppEntryPoint, don't delete no matter what IntelliJ says
function retrieveDhcPayloadDefinition (key) {
  var data = payloadStore[ key ];
  if (data) {
    delete payloadStore[ key ];
  }
  return data;
}

var MESSAGE_HANDLER = {
  mixpanel: sendMixpanel,
  mixpanel_engage: engageMixpanel,
  upgrade: handleUpgrade,
  impersonate: handleImpersonation,
  openRequest: handleOpenApiOrRequest,
  openApi: handleOpenApiOrRequest,
  checkRootNameAvailability: checkRootNameAvailability,
  notifyRunningInstances: notifyRunningInstances,
  openExtension: openExtension
};

chrome.runtime.onMessage.addListener(function (message, sender, sendResponse) {
  return message &&
    message.type &&
    MESSAGE_HANDLER[ message.type ] &&
    MESSAGE_HANDLER[ message.type ](message, sender, sendResponse);
});

chrome.runtime.onInstalled.addListener(function (details) {
  if (details.reason === 'install') {
    chrome.storage.local.set({
      'dhc.installed': 'true',
      'last_migration_ran': chrome.app.getDetails().version
    });
  }

  // In case of fresh install or update then notify the opened websites that want to be DHC aware
  if (details.reason === 'install' || details.reason === 'update') {
    updateOpenedWebsiteClientMetaTag();
  }
});

function handleUpgrade (message, sender) {
  var openedTabsUrl = chrome.extension.getViews({ type: 'tab' }).map(function (tab) {
    return tab.location.href;
  });

  chrome.storage.local.set({
    'dhc.opened.tabs': openedTabsUrl
  }, onSave);

  function onSave () {
    if (chrome.runtime.lastError) {
      // Just in case
      chrome.storage.local.remove('dhc.opened.tabs');
      return;
    }
    chrome.runtime.reload();
  }
}

function restoreLastSessionTabs () {
  chrome.storage.local.get('dhc.opened.tabs', function (openedTabs) {
    openedTabs = openedTabs[ 'dhc.opened.tabs' ];
    if (openedTabs) {
      openedTabs.forEach(function (url) {
        chrome.tabs.create({
          url: url
        }, clearOpenedTabs);
      });
    }

    function clearOpenedTabs () {
      chrome.storage.local.remove('dhc.opened.tabs');
    }
  });
}

function updateOpenedWebsiteClientMetaTag () {
  chrome.windows.getAll({}, function (windows) {
    windows.forEach(function (applicationWindow) {
      chrome.tabs.getAllInWindow(applicationWindow.id, function (tabs) {
        tabs
          .filter(function (tab) {
            return tab && tab.url && tab.url.indexOf('http') === 0;
          })
          .forEach(function (tab) {
            chrome.tabs.executeScript(tab.id, { file: 'contentScript.js' });
          });
      });
    });
  });
}


function sendMixpanel (message) {
  var json = JSON.stringify(message.payload);
  var base64Encoded = base64Encode(json);
  fetch("https://api.mixpanel.com/track/?data=" + base64Encoded + "&ip=1");
}

function engageMixpanel (message) {
  var json = JSON.stringify(message.payload);
  var base64Encoded = base64Encode(json);
  fetch("https://api.mixpanel.com/engage/?data=" + base64Encoded + "&ip=1");
}

function handleImpersonation (message, sender) {
  var extensionBaseUrl = 'chrome-extension://' + chrome.runtime.id + '/restlet_client.html';
  // Close other tabs for impersonation to be able to clear the DB
  chrome.extension.getViews()
    .forEach(function (viewWindow) {
      if (viewWindow.location.href.indexOf(extensionBaseUrl) === 0) {
        viewWindow.close();
      }
    });

  //  Start the impersonation
  chrome.tabs.create({
    url: extensionBaseUrl + message.hash,
    active: true
  });

  // Close the impersonation page
  chrome.tabs.remove(sender.tab.id);
}

function handleOpenApiOrRequest (message, sender) {
  if (sender.tab == null) {
    return;
  }
  var key = guid();
  // var targetUrl = "restlet_client_dev.html?key=" + key + "&payloadType=" + message.payloadType + "&environment=staging";
  var targetUrl = "restlet_client.html?key=" + key + "&payloadType=" + message.payloadType;
  if (message.targetTab) {
    var views = chrome.extension.getViews({ type: "tab" });
    var targetTab = message.targetTab;
    for (var i = 0; i < views.length; i++) {
      var view = views[ i ];
      if (view.dhcTargetTab == targetTab) {
        view.dhcProcessPayload(message.type, message.source, message.payloadType, JSON.stringify(message.payload));
        chrome.tabs.update(view.dhcChromeTabId, { active: true });
        return;
      }
    }
    targetUrl += "&targetTab=" + targetTab
  }

  chrome.tabs.create({
    url: targetUrl,
    active: true
  }, function (tab) {
    var views = chrome.extension.getViews({ type: "tab" });
    var windowObj = views.filter(function (windowObj) {
      return windowObj.location.search.indexOf("key=" + key) > -1;
    })[ 0 ];

    if (windowObj) {
      if (typeof windowObj.dhcProcessPayload === "function") {
        windowObj.dhcProcessPayload(message.type, message.source, message.payloadType, message.payload, sender.url);
      } else if (!windowObj.dhcPayloadDefinition) {
        windowObj.dhcPayloadDefinition = {
          messageType: message.type,
          messageSource: message.source,
          payloadType: message.payloadType,
          payload: message.payload,
          url: sender.url
        }
      }
    } else {
      payloadStore[ key ] = {
        messageType: message.type,
        messageSource: message.source,
        payloadType: message.payloadType,
        payload: message.payload,
        url: sender.url
      }
    }
  });
}

function checkRootNameAvailability (message, sender, sendResponse) {
  Promise.all(
    getApplicationInstances(sender)
      .map(function (applicationWindow) {
        return new Promise(function (resolve, reject) {
          var onFailureCheckAvailability = setTimeout(reject, 5000);
          chrome.tabs.sendMessage(applicationWindow.dhcChromeTabId, message, function (isAvailable) {
            clearTimeout(onFailureCheckAvailability);
            resolve(isAvailable);
          })
        });
      })
  )
    .then(function (availabilities) {
      return availabilities.reduce(function (accumulator, availability) {
        return accumulator && availability;
      }, true);
    })
    .then(sendResponse)
    .catch(function () {
      return sendResponse(false);
    });
  return true;
}

function notifyRunningInstances (message, sender) {
  getApplicationInstances(sender)
    .forEach(function (applicationWindow) {
      return chrome.tabs.sendMessage(applicationWindow.dhcChromeTabId, message);
    });
}

function getApplicationInstances (sender) {
  return chrome.extension.getViews({ type: 'tab' })
    .filter(function (applicationWindow) {
      return applicationWindow.dhcChromeTabId !== sender.tab.id;
    });
}

function openExtension (message, sender) {
  var openConfiguration = {
    active: true,
    url: getExtensionUrl(message.isDevMode, message.queryString)
  };

  if (message.useExistingTab) {
    chrome.tabs.update(sender.tab.id, openConfiguration);
  } else {
    chrome.tabs.create(openConfiguration);
  }
}

///////////////////////
// Utility functions //
///////////////////////

function getExtensionUrl (isDevMode, queryString) {
  return `chrome-extension://${chrome.runtime.id}/restlet_client${isDevMode ? '_dev' : ''}.html${queryString || ''}`;
}

function guid () {
  function s4 () {
    return Math.floor((1 + Math.random()) * 0x10000)
      .toString(16)
      .substring(1);
  }

  return s4() + s4() + '-' + s4() + '-' + s4() + '-' +
    s4() + '-' + s4() + s4() + s4();
}

function base64Encode (data) {
  var b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/=";
  var o1, o2, o3, h1, h2, h3, h4, bits, i = 0, ac = 0, enc = "", tmp_arr = [];

  if (!data) {
    return data;
  }

  data = utf8Encode(data);

  do { // pack three octets into four hexets
    o1 = data.charCodeAt(i++);
    o2 = data.charCodeAt(i++);
    o3 = data.charCodeAt(i++);

    bits = o1 << 16 | o2 << 8 | o3;

    h1 = bits >> 18 & 0x3f;
    h2 = bits >> 12 & 0x3f;
    h3 = bits >> 6 & 0x3f;
    h4 = bits & 0x3f;

    // use hexets to index into b64, and append result to encoded string
    tmp_arr[ ac++ ] = b64.charAt(h1) + b64.charAt(h2) + b64.charAt(h3) + b64.charAt(h4);
  } while (i < data.length);

  enc = tmp_arr.join('');

  switch (data.length % 3) {
    case 1:
      enc = enc.slice(0, -2) + '==';
      break;
    case 2:
      enc = enc.slice(0, -1) + '=';
      break;
  }

  return enc;
};

function utf8Encode (string) {
  string = (string + '').replace(/\r\n/g, "\n").replace(/\r/g, "\n");

  var utftext = "",
    start,
    end;
  var stringl = 0,
    n;

  start = end = 0;
  stringl = string.length;

  for (n = 0; n < stringl; n++) {
    var c1 = string.charCodeAt(n);
    var enc = null;

    if (c1 < 128) {
      end++;
    } else if ((c1 > 127) && (c1 < 2048)) {
      enc = String.fromCharCode((c1 >> 6) | 192, (c1 & 63) | 128);
    } else {
      enc = String.fromCharCode((c1 >> 12) | 224, ((c1 >> 6) & 63) | 128, (c1 & 63) | 128);
    }
    if (enc !== null) {
      if (end > start) {
        utftext += string.substring(start, end);
      }
      utftext += enc;
      start = end = n + 1;
    }
  }

  if (end > start) {
    utftext += string.substring(start, string.length);
  }

  return utftext;
};
