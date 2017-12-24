(function($) {

  var chromeTabs,
      shellTemplate, tabTemplate, iframeFixTemplate,
      defaultTabTitle, defaultNewTabData, defaultTabWidths,
      currentMaxId;

  currentMaxId = 0;

  shellTemplate =
  '<div class="chrome-tabs-shell">\n' +
    '<div class="chrome-tabs"></div>\n' +
  '</div>\n';

  tabTemplate =
  '<div class="chrome-tab">\n' +
    '<div class="chrome-tab-title"></div>\n' +
    '<div class="chrome-tab-close"></div>\n' +
  '</div>\n';

  iframeFixTemplate =
  '<div class="ui-sortable-iframeFix"></div>';

  defaultTabTitle = App.Strings.tab_title_new_connection;

  defaultNewTabData = {
    title: defaultTabTitle,
    favicon: '',
    data: {
      id: 0
    }
  };

  defaultTabWidths = {
    minWidth: 45,
    maxWidth: 180
  };

  chromeTabs = {

    init: function($div, viewer) {
      var self = this;

      self.maxTabs = 5;

      self.viewer = viewer;

      // add shell to given div
      self.$shell = $(shellTemplate).appendTo($div);

      // add iframe mask to body
      self.$iframeFix = $(iframeFixTemplate).appendTo("body");

      $.extend(self.$shell.data(), defaultTabWidths);
      self.$shell.find('.chrome-tab').each(function() {
        return $(this).data().tabData = {
          data: {}
        };
      });

      if (self.maxTabs > 1) {
        self.addNewTabButton();
      }
      self.addNewTab();
      self.setupShellEvents();

      $(window).resize(function() {
        self.render();
      });

      self.render();
    },

    render: function() {
      var self = this;

      self.fixTabSizes();
      self.fixZIndexes();
      self.setupTabEvents();
      self.setupSortable();
      self.setupMask();

      return self.$shell.trigger('chromeTabRender');
    },

    setupSortable: function() {
      var self = this;

      var $tabs;
      $tabs = self.$shell.find('.chrome-tabs');
      $tabs.sortable({
        axis: 'x',
        containment: '.chrome-tabs-shell',
        tolerance: 'pointer',
        start: function(e, ui) {
          self.hideNewTabButton();
          self.fixZIndexes();
          if (!$(ui.item).hasClass('chrome-tab-current')) {
            return $tabs.sortable('option', 'zIndex', $(ui.item).data().zIndex);
          } else {
            return $tabs.sortable('option', 'zIndex', $tabs.length + 40);
          }
        },
        stop: function(e, ui) {
          var tabNum = self.$shell.find('.chrome-tab').length;
          if (tabNum < self.maxTabs) {
            self.showNewTabButton();
          }
          return self.setCurrentTab($(ui.item));
        },
        sort: function(e, ui) {
          $('#tab-bar-border-mask').css({
            left: self.getLeftAbsolutePosition($(ui.item))
          });
        }
      });

      self.setupIframeFix();
    },

    fixTabSizes: function() {
      var self = this;

      var $tabs = self.$shell.find('.chrome-tab');
      var spaceForTabBar = self.$shell.width() - 40;
      var newButtonWidth = $('#chrome-tabs-new').outerWidth(true);
      var spaceForTabs = ($tabs.length < self.maxTabs) ? spaceForTabBar - newButtonWidth : spaceForTabBar;
      var spacePerTab = Math.floor(spaceForTabs / $tabs.length);
      var tabWidth = Math.max(self.$shell.data().minWidth, Math.min(self.$shell.data().maxWidth, spacePerTab));
      var tabMargin = (parseInt($tabs.first().css('marginLeft'), 10) + parseInt($tabs.first().css('marginRight'), 10)) || 0;

      self.setNewTabButtonOffset((tabWidth - tabMargin) * $tabs.length);

      $tabs.css({
        width: tabWidth
      });
    },

    fixZIndexes: function() {
      var self = this;

      var $tabs;
      $tabs = self.$shell.find('.chrome-tab');

      $tabs.each(function(i) {
        var $tab, zIndex;
        $tab = $(this);
        zIndex = $tabs.length - i;
        if ($tab.hasClass('chrome-tab-current')) {
          zIndex = $tabs.length + 40;
        }
        $tab.css({
          zIndex: zIndex
        });
        return $tab.data({
          zIndex: zIndex
        });
      });
    },

    setupShellEvents: function() {
      var self = this;
      var $shell = self.$shell;

      $shell.find('.chrome-tabs-new').unbind('click').click(function() {
        self.addNewTab();
      });
    },

    // This is to enable tab-dragging when the mouse moves onto the
    //  iframe halfway.
    // Without iframeFix, mouse events will be captured by the
    //  iframe instead of the parent page once the mouse enters
    //  iframe. If this happens while one of the tabs is being
    //  dragged around, the drag (defined by jQuery UI sortable)
    //  would stop and the tab would end up in a strange position.
    // The solution is to create a transparent div called iframeFix,
    //  which overlaps the entire iframe. The div is shown when a
    //  mousedown event is detected on any of the tabs, and is
    //  hidden when a mouseup event is detected within the scope of
    //  the document. As iframeFix is in the same document as the
    //  tab bar, mouse events will be captured properly.
    setupIframeFix: function() {
      var self = this;
      var tabBarHeight = self.$shell.outerHeight() + self.$shell.offset().top;

      self.$iframeFix.css({
        top: tabBarHeight+"px"
      });

      self.$shell.find('.chrome-tab').each(function() {
        var $tab = $(this);
        $tab.bind('mousedown', function() {
          self.$iframeFix.show();
        });
      });

      $(document).bind('mouseup', function() {
        self.$iframeFix.hide();
      });
    },

    setupTabEvents: function() {
      var self = this;

      var $shell = self.$shell;

      $shell.find('.chrome-tab').each(function() {
        var $tab;
        $tab = $(this);
        $tab.unbind('mousedown').mousedown(function() {
          return self.setCurrentTab($tab);
        });
        return $tab.find('.chrome-tab-close').unbind('click').click(function() {
          return self.closeTab($tab);
        });
      });
    },

    setupMask: function() {
      var self = this;

      var $currentTab = self.$shell.find('.chrome-tab-current');
      $('#tab-bar-border-mask').css({
        width: $currentTab.width(),
        left: self.getLeftAbsolutePosition($currentTab)
      });
    },

    addNewTab: function(newTabData) {
      var self = this;

      var $shell = self.$shell;
      var tabNum = $shell.find('.chrome-tab').length;

      if (tabNum === self.maxTabs) {
        return;
      } else if (tabNum === self.maxTabs - 1) {
        self.hideNewTabButton();
      }

      var $newTab, tabData;
      $newTab = $(tabTemplate);
      $shell.find('.chrome-tabs').append($newTab);
      tabData = $.extend(true, {}, defaultNewTabData, newTabData);
      $newTab.data('id', currentMaxId);
      // add id for each tab and each close button for ease of testing
      $newTab.attr('id', 'chrome-tab-' + currentMaxId);
      $newTab.find('.chrome-tab-close').attr('id', 'chrome-tab-close-' + currentMaxId);
      currentMaxId++;
      self.updateTab($newTab, tabData);
      // add iframe to page
      var elementString = '<iframe id="tabs-' + $newTab.data('id') + '" seamless src="viewer.html?owned=1"/>';
      $('#content').append(elementString);
      var idString = '#tabs-' + $newTab.data('id');
      var iframeWindow = $(idString).get(0).contentWindow;

      self.setCurrentTab($newTab);

      self.viewer.addTabMapping($newTab.data('id'), iframeWindow);
    },

    setCurrentTab: function($tab) {
      var self = this;

      var $oldTab = self.$shell.find('.chrome-tab-current');
      $('#tabs-' + $oldTab.data('id')).hide();
      $oldTab.removeClass('chrome-tab-current');
      $tab.addClass('chrome-tab-current');
      $('#tabs-' + $tab.data('id')).show();

      self.viewer.setActiveTabId($tab.data('id'));
      $(self.viewer).trigger('refocus');

      self.render();

      $(window).trigger('tabchange');
    },

    closeTab: function($tab) {
      var self = this;

      // remove iframe element
      var elementID = '#tabs-' + $tab.data('id');
      $(elementID).remove();

      if ($tab.hasClass('chrome-tab-current')) {
        if ($tab.next().length) {
          self.setCurrentTab($tab.next());
        } else if ($tab.prev().length) {
          self.setCurrentTab($tab.prev());
        } else {
          // If closing final tab, close the app.
          window.close();
        }
      }

      self.viewer.removeTabMapping($tab.data('id'));

      $tab.remove();

      var tabNum = self.$shell.find('.chrome-tab').length;
      if (tabNum === self.maxTabs - 1) {
        self.showNewTabButton();
      }

      return self.render();
    },

    updateTab: function($tab, tabData) {
      $tab.find('.chrome-tab-title').html(tabData.title);
      $tab.find('.chrome-tab-favicon').css({
        backgroundImage: "url('" + tabData.favicon + "')"
      });

      return $tab.data().tabData = tabData;
    },

    updateTabTitle: function(id, title) {
      var self = this;

      self.getTabById(id).find('.chrome-tab-title').html(title);
    },

    resetTabTitle: function(id) {
      var self = this;
      self.getTabById(id).find('.chrome-tab-title').html(defaultTabTitle);
    },

    getIdByTab: function($tab) {
      return $tab.data('id');
    },

    getTabById: function(id) {
      var self = this;

      return self.$shell.find('.chrome-tab').filter(function() {
        return $(this).data('id') === id;
      });
    },

    addNewTabButton: function() {
      var self = this;

      self.$shell.append('<div id="chrome-tabs-new" class="chrome-tabs-new"></div>');
    },

    hideNewTabButton: function() {
      var self = this;

      self.$shell.find('.chrome-tabs-new').hide();
    },

    showNewTabButton: function() {
      var self = this;

      self.$shell.find('.chrome-tabs-new').show();
    },

    setNewTabButtonOffset: function(offset) {
      var self = this;

      self.$shell.find('.chrome-tabs-new').css('left', offset);
    },

    getLeftAbsolutePosition: function($tab) {
        return parseInt($tab.offset().left, 10) + parseInt($tab.css('border-left-width'), 10);
    }
  };

  window.chromeTabs = chromeTabs;

})(jQuery);
