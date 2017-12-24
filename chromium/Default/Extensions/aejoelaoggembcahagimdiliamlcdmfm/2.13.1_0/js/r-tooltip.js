/*
 * Copyright 2010-2017 Restlet S.A.S. All rights reserved.
 * Restlet is registered trademark of Restlet S.A.S.
 */

/*
 * see https://github.com/twbs/bootstrap/blob/v2.3.2/js/bootstrap-popover.js
 *
 **/

!function ($) {

  "use strict"; // jshint ;_;


  /* TOOLTIP PUBLIC CLASS DEFINITION
   * =============================== */

  var rTooltip = function (element, options) {
    this.init('rTooltip', element, options)
  }


  /* NOTE: EXTENDS BOOTSTRAP-TOOLTIP.js
   ========================================== */

  rTooltip.prototype = $.extend({}, $.fn.tooltip.Constructor.prototype, {

    constructor: rTooltip

    , enter: function () {
      clearTimeout(this.timeout);
      var self = this.$element.data()[ this.type ];

      if (!self.options.delay || !self.options.delay.show) return self.show();

      this.timeout = setTimeout(function () {
        self.show();
      }, self.options.delay.show);
    }

    , leave: function () {
      var that = this;

      clearTimeout(that.timeout);

      var self = that.$element.data()[ that.type ];
      if (!self.options.delay || !self.options.delay.hide) return self.hide();

      // if we still hover the element don't do anything
      if ($(that.$element).is(':hover')) {
        return;
      }

      var $tip = that.tip();
      $tip.off('mouseleave');

      that.timeout = setTimeout(function () {
        if ($tip.is(':hover')) {
          $tip.on('mouseleave', $.proxy(that.leave, that));
        } else if (!$(that.$element).is(':hover')) {
          self.hide();
        }
      }, self.options.delay.hide)
    }

    , hide: function () {
      var $tip = this.tip()
        , e = $.Event('hide');

      this.$element.trigger(e);
      if (e.isDefaultPrevented()) return;

      $tip.removeClass('in');

      $tip.detach();

      this.$element.trigger('hidden');

      return this;
    }

  })


  /* TOOLTIP PLUGIN DEFINITION
   * ======================= */

  var old = $.fn.rTooltip

  $.fn.rTooltip = function (option) {
    return this.each(function () {
      var $this = $(this)
        , data = $this.data('rTooltip')
        , options = typeof option == 'object' && option
      if (!data) $this.data('rTooltip', (data = new rTooltip(this, options)))
      if (typeof option == 'string') data[ option ]()
    })
  }

  $.fn.rTooltip.Constructor = rTooltip

  $.fn.rTooltip.defaults = $.extend({}, $.fn.tooltip.defaults, {
    html: true
    ,
    template: '<div class="r-tooltip tooltip"><div class="tooltip-arrow"></div><div class="tooltip-inner"></div></div>'
  })


  /* TOOLTIP NO CONFLICT
   * =================== */

  $.fn.rTooltip.noConflict = function () {
    $.fn.rTooltip = old
    return this
  }

}(window.jQuery);
