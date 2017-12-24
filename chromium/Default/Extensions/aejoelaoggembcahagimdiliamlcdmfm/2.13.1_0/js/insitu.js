/*
 * Copyright 2010-2017 Restlet S.A.S. All rights reserved.
 * Restlet is registered trademark of Restlet S.A.S.
 */

!function ($) {
  'use strict';

  // redefine `_` as the `_` from window is GWT's temporary variable
  var _ = window.RESTLET._;

  var INSITUS = [
    // examples from 2.12:
    // { key: 'newdraft_2110', placement: 'bottom' },
    // { key: 'save_2110', placement: 'left' }
  ];

  //
  // `allInsituKeys` are for external usage,
  // e.g.: `$wnd.RESTLET.insitusService.hideInsitu($wnd.RESTLET.insitusService.keys.print_report_240);`
  //
  var allInsituKeys = _.reduce(INSITUS, function (accu, insitu) {
    accu[insitu.key] = insitu.key;
    return accu;
  }, {});

  window.RESTLET.insitusService = {
    setInsitusForFirstInstallation: setInsitusForFirstInstallation,
    loadInsituForUnsigned: loadInsituForUnsigned,
    loadInsituForSignedUser: loadInsituForSignedUser,
    onSignin: onSignin,
    onSignup: onSignup,
    onSignout: onSignout,
    fireInsitu: fireInsitu,
    hideInsitu: hideInsitu,
    keys: allInsituKeys,
    /* Example:
    keys: {
     'export_to_maven_240': 'export_to_maven_240',
     'print_report_240': 'print_report_240'
     }*/
    viewedInsitus: [],
    insituWaitingToBeDisplayed: null
  };

  var insitusService = window.RESTLET.insitusService;
  var STORAGE_KEY_ = 'viewed-insitu-messages-';
  var COMMON_USER_ID = 'common';

  var CSS_FREE_TRIAL_AVAILABLE = 'free-trial-available';
  var CSS_FREE_TRIAL_NOT_AVAILABLE = 'free-trial-unavailable';

  var currentElementWithPopover;

  function setInsitusForFirstInstallation () {
    var allInsitus = _.map(INSITUS, 'key');
    saveInStorage(COMMON_USER_ID, allInsitus);
  }

  function loadInsituForUnsigned () {
    readViewedInsitus(COMMON_USER_ID)
        .then(function (result) {
          insitusService.viewedInsitus = result.viewedInsitus;
          showInsituToUser(insitusService.viewedInsitus, true /* isFreeTrialAvailable */);
        });
  }

  function loadInsituForSignedUser (userId, isFreeTrialAvailable) {

    isUserInStorage(userId)
        .then(function (isInStorage) {
          if (isInStorage) {

            readViewedInsitus(userId)
                .then(function (result) {
                  insitusService.viewedInsitus = result.viewedInsitus;
                  showInsituToUser(insitusService.viewedInsitus, isFreeTrialAvailable);

                  // init `common` and remove `user`
                  saveInStorage(COMMON_USER_ID, insitusService.viewedInsitus,
                      _.partial(removeUserFromStorage, userId));
                });

          } else {

            readViewedInsitus(COMMON_USER_ID)
                .then(function (result) {
                  insitusService.viewedInsitus = result.viewedInsitus;
                  showInsituToUser(insitusService.viewedInsitus, isFreeTrialAvailable);
                });
          }
        });

  }

  function onSignin (userId, isFreeTrialAvailable) {

    isUserInStorage(userId)
        .then(function (isInStorage) {

          if (isInStorage) {

            readViewedInsitus(userId)
                .then(function (result) {

                  var userVieweds = result.viewedInsitus;
                  var commonVieweds = insitusService.viewedInsitus;

                  insitusService.viewedInsitus = _.union(commonVieweds, userVieweds);
                  showInsituToUser(insitusService.viewedInsitus, isFreeTrialAvailable);

                  // remove `user`
                  saveInStorage(COMMON_USER_ID, insitusService.viewedInsitus,
                      _.partial(removeUserFromStorage, userId));
                });
          }

          refreshDisplayOfCurrentInsitu(isFreeTrialAvailable);
        });
  }

  function onSignup (userId, isFreeTrialAvailable) {
    refreshDisplayOfCurrentInsitu(isFreeTrialAvailable);
  }

  function onSignout () {
    refreshDisplayOfCurrentInsitu(true /* isFreeTrialAvailable */);
  }

  function refreshDisplayOfCurrentInsitu (isFreeTrialAvailable) {

    if (currentElementWithPopover) {
      var tip = currentElementWithPopover.data('r-popover').tip();
      tip.removeClass([CSS_FREE_TRIAL_AVAILABLE, CSS_FREE_TRIAL_NOT_AVAILABLE].join(' '));
      tip.addClass(isFreeTrialAvailable ? CSS_FREE_TRIAL_AVAILABLE : CSS_FREE_TRIAL_NOT_AVAILABLE);
    }
  }

  function fireInsitu (cssOfAvailableElement, isFreeTrialAvailable) {
    if (!_.get(insitusService, 'insituWaitingToBeDisplayed')) {
      return;
    }

    if (cssOfAvailableElement.includes(insitusService.insituWaitingToBeDisplayed.key)) {
      showInsituToUser(insitusService.viewedInsitus, isFreeTrialAvailable);
    }

  }

  function removeUserFromStorage (userId) {
    var key = STORAGE_KEY_ + userId;
    chrome.storage.local.remove(key);
  }

  function isUserInStorage (userId) {

    var key = STORAGE_KEY_ + userId;

    return new Promise(function (resolve, reject) {

      chrome.storage.local.get(key, function (storedVieweds) {

        // Note: `local.get` returns an empty object `{}` if it doesn't find a stored item for the specified `key`
        // e.g. it doesn't return `undefined` nor `null`
        var isInStorage = _.has(storedVieweds, key);
        resolve(isInStorage);
      })
    });
  }

  function readViewedInsitus (userId) {

    var key = STORAGE_KEY_ + userId;

    return new Promise(function (resolve, reject) {

      chrome.storage.local.get(key, function (storedVieweds) {

        // Note: `local.get` returns an empty object `{}` if it doesn't find a stored item for the specified `key`
        // e.g. it doesn't return `undefined` nor `null`

        var vieweds = storedVieweds[key] || [];

        resolve({
          viewedInsitus: vieweds
        });

      });

    });

  }

  function showInsituToUser (viewedInsitus, isFreeTrialAvailable) {

    var insituKeyToDisplay = getInsituKeyToDisplay(viewedInsitus);

    if (insituKeyToDisplay) {

      var insituToDisplay = _.find(INSITUS, { key: insituKeyToDisplay });

      var elementToApplyInsitu = $('.' + insituKeyToDisplay);
      if (!_.isEmpty(elementToApplyInsitu)) {
        show(insituToDisplay, elementToApplyInsitu.first() /* you may have several results */, isFreeTrialAvailable);

      } else {
        insitusService.insituWaitingToBeDisplayed = insituToDisplay;
      }
    }
  }

  function getInsituKeyToDisplay (viewedInsitus) {

    var allInsitus = _.map(INSITUS, 'key');
    var insitusToBeViewed = _.difference(allInsitus, viewedInsitus);

    return _.first(insitusToBeViewed);
  }

  function show (insitu, elementToApplyInsitu, isFreeTrialAvailable) {

    hideCurrent();

    var additionalClass = isFreeTrialAvailable ? CSS_FREE_TRIAL_AVAILABLE : CSS_FREE_TRIAL_NOT_AVAILABLE;
    newPopover(insitu, elementToApplyInsitu, additionalClass);

    setTimeout(function () {

      currentElementWithPopover.rPopover('show');

      //
      // attach click handler to the insitu's button
      // because GWT does not allow inlined `onclick`
      //
      var actionBtn = $('.' + getFullKey(insitu) + ' button');
      if (actionBtn) {
        actionBtn.click(function () {
          closeAndAcknowledge(insitu.key, isFreeTrialAvailable);
        });
      }

    }, 300 /* gives time for UI to render properly */);

  }

  function closeAndAcknowledge (insituKey, isFreeTrialAvailable) {
    hideCurrent();

    // save
    insitusService.viewedInsitus.push(insituKey);
    saveInStorage(COMMON_USER_ID, insitusService.viewedInsitus);

    // show next
    showInsituToUser(insitusService.viewedInsitus, isFreeTrialAvailable);
  }

  function newPopover (insitu, elementToApplyInsitu) {
    var additionalClasses = Array.prototype.slice.call(arguments, 2);

    var fullKey = getFullKey(insitu);
    var customClasses = _.flatten(['r-whatsnew-insitu', fullKey, additionalClasses]);

    var options = {
      animation: true,
      customClass: customClasses.join(' '),
      html: true,
      placement: insitu.placement,
      templateId: fullKey,
      trigger: 'manual'
    };

    elementToApplyInsitu.rPopover(options);
    currentElementWithPopover = elementToApplyInsitu;
  }

  function hideInsitu (insituKey) {

    if (currentElementWithPopover
        && currentElementWithPopover.hasClass(insituKey)) {
      closeAndAcknowledge(insituKey);
    }

  }

  function hideCurrent () {
    if (currentElementWithPopover) {
      currentElementWithPopover.rPopover('destroy');
      currentElementWithPopover = null;

      if (_.get(insitusService, 'insituWaitingToBeDisplayed')) {
        insitusService.insituWaitingToBeDisplayed = null;
      }

    }
  }

  function getFullKey (insitu) {
    return 'r_insitu_' + insitu.key;
  }

  function saveInStorage (userId, viewedInsitus, callback) {

    var afterSettingCb = callback || _.noop;

    chrome.storage.local.set({
      [STORAGE_KEY_ + userId]: viewedInsitus
    }, afterSettingCb);
  }

}(window.jQuery);

