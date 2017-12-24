/*
 * Copyright 2010-2017 Restlet S.A.S. All rights reserved.
 * Restlet is registered trademark of Restlet S.A.S.
 */

!function () {
  'use strict';

  var setCookie = window.RESTLET.cookieUtils.setCookie;
  var readCookie = window.RESTLET.cookieUtils.readCookie;

  var createMixpanelCookie = function (distinctId, mixpanelId, domain) {
    setCookie({
      name: 'mp_' + mixpanelId + '_mixpanel',
      domain,
      value: {
        "distinct_id": distinctId,
        "$initial_referrer": location.origin,
        "$initial_referring_domain": location.origin
      }
    });
  };

  var readMixpanelCookie = function (mixpanelId, domain) {
    return readCookie({domain, name: 'mp_' + mixpanelId + '_mixpanel'});
  };

  window.RESTLET.mixpanelService = {
    createMixpanelCookie: createMixpanelCookie,
    readMixpanelCookie: readMixpanelCookie
  };

}();
