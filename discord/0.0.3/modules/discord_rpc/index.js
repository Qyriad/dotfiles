
if (process.platform == 'linux') {
  module.exports = require('ws');
}
else {
  module.exports = require('./uws.js');
}

const fs = require('fs');
const path = require('path');

module.exports.Proxy = require('http-proxy');
