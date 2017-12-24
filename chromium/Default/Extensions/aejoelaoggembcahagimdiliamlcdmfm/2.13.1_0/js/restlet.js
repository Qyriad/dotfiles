/*
 * Copyright 2010-2017 Restlet S.A.S. All rights reserved.
 * Restlet is registered trademark of Restlet S.A.S.
 */

// `!` see http://benalman.com/news/2010/11/immediately-invoked-function-expression/
!function () {
  'use strict';

  window.RESTLET = {
    _: _
  };

  // check that lodash is loaded and `_` is lodash and not the GWT temporary variable
  // see http://stackoverflow.com/questions/5598074/understanding-gwt-compiler-output
  // see http://stackoverflow.com/questions/9824763/gwt-polluting-global-javascript-namespace

  console.assert(window.RESTLET._.VERSION, '4.17.4');

}();
