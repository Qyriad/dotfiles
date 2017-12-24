var log = function (msg) {
  console.log(msg);
};

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
  if (!event.data.type) {
    log("Messaged is ignored since 'type' property is missing");
    return;
  }
  log("Message is valid, delegating it to Restlet Client");

  chrome.runtime.sendMessage(event.data, function (response) {
    window.close();
  });
}, false);

