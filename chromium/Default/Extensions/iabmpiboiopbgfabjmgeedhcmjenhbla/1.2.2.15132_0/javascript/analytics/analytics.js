(function($) {
  App.Controller.Analytics = function(viewer) {
    this.init(viewer);
  };
  jQuery.extend(App.Controller.Analytics.prototype, {
    init: function(viewer) {
      var self = this;
      self.viewer = viewer;
      self.state = null;
      self.viewer.addStateDelegate(self);
      self.analyticsEnabled = false;
    },
    // State Delegate
    onStateChanged: function(state) {
      var self = this;
      self.state = state;
      if (self.analyticsEnabled) {
        self.reportVersion();
      }
    },
    enableAnalytics: function() {
      var self = this;
      self.analyticsEnabled = true;
      /* Custom variables to be pushed back to Google */
      /* See https://developers.google.com/analytics/devguides/collection/gajs/gaTrackingCustomVariables */
      _gaq.push(['_setCustomVar',
                 1, // Using the 1st of the 5 available slots
                 'AppVersion', // Name of the custom variable
                 "1.2.2.15132", // Value ot the custom variable
                 3 // Scope of tracking.
                 // 1=user. 2=session. 3=page.
                ]);
      _gaq.push(['_setCustomVar',
                 1,
                 'Tabbed',
                 "2",
                 3
                ]);
      _gaq.push(['_trackPageview']); // Send custom variables
      self.reportVersion();
    },
    reportVersion: function() {
      var self = this;
      if (self.state == App.ViewerKit.State.CONNECTED) {
        var rfbVersionMajor = 0;
        var rfbVersionMinor = 0;
        self.viewer.getProperty(App.ViewerKit.Property.RFB_VERSION_MAJOR, function(result) {
          rfbVersionMajor = result;
          self.viewer.getProperty(App.ViewerKit.Property.RFB_VERSION_MINOR, function(result) {
            rfbVersionMinor = result;
            var protocolVer = App.Strings.text_protocol_version.replace("%d", rfbVersionMajor).replace("%d", rfbVersionMinor);
            // Reporting RFB version to Google Analytics
            _gaq.push(['_trackEvent',
                       'Connection',
                       'RFB_Version',
                       protocolVer
                       ]);
          });
        });
      }
    }
  });
})(jQuery);
