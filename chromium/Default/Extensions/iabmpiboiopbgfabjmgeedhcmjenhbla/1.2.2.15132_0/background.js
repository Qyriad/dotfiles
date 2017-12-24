(function($) {
  window.toClipboard = function(text) {
    $('#clipboard').val(text).select();
    document.execCommand('copy');
  };

  window.fromClipboard = function() {
    $('#clipboard').select();
    document.execCommand('paste');
    return $('#clipboard').val();
  };
}(jQuery));
