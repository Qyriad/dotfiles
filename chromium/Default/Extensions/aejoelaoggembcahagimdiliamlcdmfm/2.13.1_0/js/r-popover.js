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


  /* POPOVER PUBLIC CLASS DEFINITION
   * =============================== */

  var rPopover = function (element, options) {
    this.init('rPopover', element, options)
  }


  /* NOTE: POPOVER EXTENDS BOOTSTRAP-TOOLTIP.js
   ========================================== */

  rPopover.prototype = $.extend({}, $.fn.tooltip.Constructor.prototype, {

    constructor: rPopover

    , setContent: function () {
      var $tip = this.tip()
          , customClass = this.options.customClass
          , content = this.getContent()

      if (customClass) {
        $tip.addClass(customClass);
      }

      $tip.find('.popover-content')['html'](content)

      $tip.removeClass('fade top bottom left right in')
    }

    , hasContent: function () {
      return this.getTitle() || this.getContent()
    }

    , getContent: function () {
      var content
          , $e = this.$element
          , o = this.options

      if (this.options.templateId) {

        var template = $(`#${this.options.templateId}[type="text/r-template"]`);

        if (!template.length) {
          throw new Error(`Template #${this.options.templateId} not found!`);
        }

        var templateContent = template.html();
        return templateContent;
      }

      content = (typeof o.content == 'function' ? o.content.call($e[0]) : o.content)
          || $e.attr('data-content')

      return content
    }

    , tip: function () {
      if (!this.$tip) {
        this.$tip = $(this.options.template)
      }
      return this.$tip
    }

    , destroy: function () {
      this.hide().$element.off('.' + this.type).removeData(this.type)
    }

  })


  /* POPOVER PLUGIN DEFINITION
   * ======================= */

  var old = $.fn.rPopover

  $.fn.rPopover = function (option) {
    return this.each(function () {
      var $this = $(this)
          , data = $this.data('rPopover')
          , options = typeof option == 'object' && option
      if (!data) $this.data('rPopover', (data = new rPopover(this, options)))
      if (typeof option == 'string') data[option]()
    })
  }

  $.fn.rPopover.Constructor = rPopover

  $.fn.rPopover.defaults = $.extend({}, $.fn.tooltip.defaults, {
    placement: 'right'
    ,
    trigger: 'click'
    ,
    content: ''
    ,
    template: '<div class="r-popover popover"><div class="arrow"></div><div class="popover-content"></div></div>'
  })


  /* POPOVER NO CONFLICT
   * =================== */

  $.fn.rPopover.noConflict = function () {
    $.fn.rPopover = old
    return this
  }

}(window.jQuery);
