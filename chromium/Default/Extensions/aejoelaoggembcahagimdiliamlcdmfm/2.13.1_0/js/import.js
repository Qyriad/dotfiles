/*
 * Copyright 2010-2017 Restlet S.A.S. All rights reserved.
 * Restlet is registered trademark of Restlet S.A.S.
 */

!function () {
  'use strict';

  var _ = window.RESTLET._;

  window.RESTLET.importPostmanCollectionV2 = function (postmanJson) {
    var project = {
      updateType: 'Create',
      entity: {
        type: 'Project',
        name: postmanJson.info.name,
        description: postmanJson.info.description
      },
      children: createChildren(postmanJson.item, [])
    };
    return project;
  };

  function createChildren (items, children) {
    _(items)
        .forEach(function (item) {
          if (item.request) {
            children.push(createRequest(item));
          } else {
            createService(item, children);
          }
        });
    return children;
  }

  function createService (item, children) {
    var service = {
      updateType: 'Create',
      entity: {
        type: 'Service',
        name: item.name,
        description: item.description
      },
      children: []
    };
    children.push(service);

    var serviceChildren = createChildren(item.item, []);

    _.forEach(serviceChildren, function (child) {
      if (child.entity.type === 'Service') {
        children.push(child);
      } else {
        service.children.push(child);
      }
    });
  }

  function createRequest (item) {
    return {
      updateType: 'Create',
      entity: {
        type: 'Request',
        name: item.name,
        description: item.request.description,
        method: getMethod(item.request.method),
        uri: {
          scheme: getScheme(item.request.url),
          path: getPath(item.request.url)
        },
        headers: getHeaders(item.request.header),
        body: getBody(item.request.body),
        headersType: 'Form',
        assertions: extractAssertions(item.event)
      },
      children: []
    };
  }

  function extractAssertions (eventList) {
    return _(eventList)
        .filter(function (event) {
          return event.listen === 'test';
        })
        .filter(function (testCase) {
          return testCase.script && testCase.script.type === 'text/javascript';
        })
        .map(function (testCase) {
          return testCase.script.exec;
        })
        .flatten()
        .uniq()
        .reduce(function (assertions, postmanAssertion) {
          // Search for status code test
          var statusCodeRegex1 = /tests\[.*?\]\s*=\s*responseCode.code\s*===\s*([0-9]+)/i;
          var statusCodeRegex2 = /tests\[.*?\]\s*=\s*([0-9]+)\s*===\s*responseCode.code/i;

          var statusCode = statusCodeRegex1.exec(postmanAssertion);
          if (_.size(statusCode) > 1) {
            assertions.push({
              comparison: 'Equals',
              subject: 'ResponseStatus',
              path: 'code',
              enabled: true,
              value: statusCode[1]
            });
          } else {
            statusCode = statusCodeRegex2.exec(postmanAssertion);
            if (_.size(statusCode) > 1) {
              assertions.push({
                comparison: 'Equals',
                subject: 'ResponseStatus',
                path: 'code',
                enabled: true,
                value: statusCode[1]
              });
            }
          }

          // Search for body assertions
          var bodyContent = /tests\[.*?\]\s*=\s*responseBody.has\((?:"|')(.*)(?:"|')\)/i;
          var bodyAssertion = bodyContent.exec(postmanAssertion);
          if (_.size(bodyAssertion) > 1) {
            assertions.push({
              comparison: 'Contains',
              subject: 'ResponseBody',
              path: 'content',
              enabled: true,
              value: bodyAssertion[1]
            });
          }

          return assertions;
        }, []);

  }

  function getMethod (methodName) {
    return {
      requestBody: _.includes(['POST', 'PUT', 'PATCH', 'DELETE'], methodName),
      link: 'https://tools.ietf.org/html/rfc7231#section-4.3',
      name: methodName
    };
  }

  function getScheme (url) {
    url = typeof(url) === 'object' ? url.raw : url;
    if (!url || url.indexOf('https') === 0) {
      return {
        secure: true,
        name: 'https',
        version: 'V11'
      };
    } else {
      return {
        secure: false,
        name: 'http',
        version: 'V11'
      };
    }
  }

  function getPath (url) {
    url = typeof(url) === 'object' ? url.raw : url;
    if (!url) {
      return '';
    } else {
      return url.substring(url.indexOf('://') + 3);
    }
  }

  function getHeaders (headers) {
    return _.map(headers, function (header) {
      return {
        enabled: true,
        name: header.key,
        value: header.value
      };
    });
  }

  function getBody (body) {
    if (body.mode === 'raw') {
      return {
        bodyType: 'Text',
        autoSetLength: true,
        textBody: body.raw
      };
    } else if (body.mode === 'urlencoded') {
      return getFormBody(body.urlencoded, 'application/x-www-form-urlencoded');
    } else if (body.mode === 'formdata') {
      return getFormBody(body.formdata, 'multipart/form-data');
    } else if (body.mode === 'binary') {
      return {
        bodyType: 'File',
        autoSetLength: true
      };
    } else {
      return {
        bodyType: 'Text',
        autoSetLength: true,
        textBody: ''
      };
    }
  }

  function getFormBody (bodyItems, encoding) {
    return {
      formBody: {
        overrideContentType: true,
        encoding: encoding,
        items: _.map(bodyItems, function (parameter) {
          return {
            enabled: true,
            name: parameter.key,
            value: parameter.value,
            type: parameter.type === 'file' ? 'File' : 'Text'
          };
        })
      },
      bodyType: 'Form',
      autoSetLength: true
    };
  }
}();
