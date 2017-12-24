/*
 * Copyright 2010-2017 Restlet S.A.S. All rights reserved.
 * Restlet is registered trademark of Restlet S.A.S.
 */

!function () {
  'use strict';

  var oauthLink = function (githubOauthAppId, state) {
    var redirectUrl = window.chrome.identity.getRedirectURL();
    var url = 'https://github.com/login/oauth/authorize?client_id=' + githubOauthAppId + '&scope=repo&redirect_uri=' + encodeURIComponent(redirectUrl) + '&state=' + state;

    return new Promise(
        function (resolve, reject) {
          $wnd.chrome.identity.launchWebAuthFlow({
                'url': url,
                'interactive': true
              },
              function (callbackUrl) {
                if (!callbackUrl) {
                  return reject(Error('Could not connect to GitHub. Please try again in a few seconds.'));
                }

                var queryParameters = extractQueryParameters(callbackUrl);
                if (queryParameters.error) {
                  console.log('GitHub threw an error: ', queryParameters.error_description);
                  return reject(Error('An unexpected error occurred. Please try again and contact support@restlet.com if the problem persists.'));
                }

                if (queryParameters.state !== state) {
                  return reject(Error('We detected suspicious activity while connecting to your GitHub account. As a security measure, we have cancelled the operation. Please try again.'));
                }

                return resolve({
                  linked: true,
                  appId: githubOauthAppId,
                  code: queryParameters.code,
                  state: state
                });
              });
        });
  };

  // Assumes url contains query parameters
  var extractQueryParameters = function (url) {
    var queryString = url.substring(url.indexOf('?') + 1);
    return queryString.split('&')
        .map(function (queryParameterAndValue) {
          return queryParameterAndValue.split('=');
        })
        .reduce(function (seed, pair) {
          seed[pair[0]] = pair[1];
          return seed;
        }, {})
  };

  window.RESTLET.github = {
    oauthLink: oauthLink
  };

}();
