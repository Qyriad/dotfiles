/**
 * Listens for the app launching then creates the window
 *
 * @see http://developer.chrome.com/trunk/apps/app.runtime.html
 * @see http://developer.chrome.com/trunk/apps/app.window.html
 */
chrome.app.runtime.onLaunched.addListener(function() {
  chrome.app.window.create("viewer.html", {
    bounds: {
      width: 800,
      height: 600
    },
    minWidth: 800,
    minHeight: 600
  },
  function(win) {
    // The following key events handler will prevent the default behavior for
    // the ESC key, thus will prevent the ESC key to leave fullscreen
    // when the viewer is connected to the server.
    win.contentWindow.document.addEventListener('keydown', function(e) {
        if(e.keyCode === 27){
           e.preventDefault();
        }
    });
    win.contentWindow.document.addEventListener('keyup', function(e) {
        if(e.keyCode === 27){
           e.preventDefault();
       }
    });
  });
});
