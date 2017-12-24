(function($) {

  Parser.UrlParams = function() {
    var self = this;
    self.init();
  };

  jQuery.extend(Parser.UrlParams.prototype, {
    init: function() {
      var self = this;
    },

    parse: function(paramString) {
      var self = this;
      var firstChar = paramString.charAt(0);
      var validFirstChars = ['#', '?'];
      var params = {};
      var posSeparator, name, value;

      if (!validFirstChars.some(function(validFirstChar) {
        return (firstChar === validFirstChar);
      })) {
        return {};
      }
      paramString.slice(1).split('&').forEach(function(param) {
        posSeparator = param.indexOf('=');
        if (posSeparator !== -1) {
          name = param.substring(0, posSeparator);
          value = param.substring(posSeparator + 1);
          params[name] = value;
        }
      });
      return params;
    }
  });

})(jQuery);
