(function () {
  "use strict";

  const element = document.querySelector('meta[name="dhc-aware-page"]');

  if (!element) {
    return;
  }

  let indicatorElementId = element.getAttribute("data-indicator-element-id");
  const debugEnabled = element.getAttribute("data-console-debug");
  const log = debugEnabled == "true" ? console.log.bind(console) : function () {};

  log("Restlet Client meta tag found.");

  if (indicatorElementId == null) {
    log("data-indicator-element-id is not specified, using default id 'dhcInfo'");
    indicatorElementId = "dhcInfo";
  } else {
    log("data-indicator-element-id is: '" + indicatorElementId + "'");
  }

  Array.prototype.slice.call(document.querySelectorAll(`script#${indicatorElementId}`))
      .forEach(function(element){
        if (chrome.runtime.id === JSON.parse(element.innerText).extensionId) {
          element.parentNode.removeChild(element);
        }
      });

  const scriptElement = document.createElement("script");
  scriptElement.id = indicatorElementId;
  scriptElement.type = "dhc/info";

  const dhcInfo = {
    dhcVersion: chrome.runtime.getManifest().version,
    extensionId: chrome.runtime.id
  };

  log("Dhc info is ", dhcInfo);

  log("Creating indicator tag with id: " + scriptElement.id + ", type: " + scriptElement.type);
  scriptElement.textContent = JSON.stringify(dhcInfo);
  document.documentElement.appendChild(scriptElement);

  log("Indicator tag created");
  log("Waiting for messages from target page");
  window.addEventListener("message", function (event) {
    log("Received message", event.data);
    if (event.source != window) {
      log("Message is ignored since it is from the wrong window");
      return;
    }
    if (!event.data) {
      log("Message is ignored since it is empty");
      return;
    }
    if (event.data.target != chrome.runtime.id) {
      log("Message is ignored since provided target ('" + event.data.target + "') doesn't match expected value: '" + chrome.runtime.id + "'");
      return;
    }
    if (!event.data.type) {
      log("Messaged is ignored since 'type' property is missing");
      return;
    }
    log("Message is valid, delegating it to Restlet Client");

    chrome.runtime.sendMessage(event.data, function (response) {
      //TODO process response from main DHC
    });
  }, false);


})();

