/*
 * Copyright 2010-2017 Restlet S.A.S. All rights reserved.
 * Restlet is registered trademark of Restlet S.A.S.
 */

!function () {
  'use strict';

  var removeCookie = window.RESTLET.cookieUtils.removeCookie;
  var readCookie = window.RESTLET.cookieUtils.readCookie;

  var resetAuthCookie = function (domain) {
    return removeCookie({
      domain: domain,
      name: 'restlet.auth'
    });
  };

  var readAuthCookie = function (domain) {
    return readCookie({
      domain: domain,
      name: 'restlet.auth'
    })
  };

  var readAndResetAuthCookie = function (domain) {
    return readAuthCookie(domain)
        .then(function (cookie) {
          return resetAuthCookie(domain)
              .then(function () {
                return cookie;
              });
        });
  };

  window.RESTLET.authService = {
    readAndResetAuthCookie: readAndResetAuthCookie
  };

}();
