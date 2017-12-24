/*
 * Copyright 2010-2017 Restlet S.A.S. All rights reserved.
 * Restlet is registered trademark of Restlet S.A.S.
 */

var hash = window.location.hash;
var shouldCreateNewTab = true;

var id = chrome.app.getDetails().id;
var htmlPage = '/restlet_client.html';
var tabUrl = 'chrome-extension://' + id + htmlPage;

var debug = function (text) {
  var textnode = document.createElement('div');
  textnode.innerHTML = text + '<br>';
  document.body.appendChild(textnode);
};

chrome.windows.getCurrent(function (currentWindow) {
  var extensionsTabs = chrome.extension.getViews({type: "tab", windowId: currentWindow.id});
  var launcher = extensionsTabs
      .find(function (extensionTab) {
        return extensionTab.location.pathname === '/restlet_client_launcher.html';
      });

  extensionsTabs.forEach(function (extensionTab) {
    if (extensionTab.location.pathname === htmlPage && shouldCreateNewTab) {

      shouldCreateNewTab = false;
      if (hash && extensionTab.location.hash !== hash) {
        chrome.tabs.update(extensionTab.dhcChromeTabId, {active: true, url: tabUrl + hash});

      } else {
        chrome.tabs.update(extensionTab.dhcChromeTabId, {active: true});

      }
    }
  });

  if (shouldCreateNewTab) {
    chrome.tabs.create({
      url: tabUrl + hash
    });
  }

  if (launcher) {
    launcher.close();
  }
  window.close();
});

