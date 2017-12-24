/**
 * Listens for the app launching then creates the window
 *
 * @see http://developer.chrome.com/trunk/apps/app.runtime.html
 * @see http://developer.chrome.com/trunk/apps/app.window.html
 */
chrome.app.runtime.onLaunched.addListener(function() {
  // Launches app without showing "First Run" or "What's New" dialogs
  chrome.storage.local.set({'first-run': false}, function() {
    chrome.storage.local.set({'last-used-version': "1.2.2.15132"}, function() {
      chrome.app.window.create("viewer.html", {
        bounds: {
          width: 800,
      height: 600
        },
      minWidth: 800,
      minHeight: 600
      });
    });
  });
});
