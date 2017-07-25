'use strict';

module.exports = (ngModule) => {
  // Load configs within this file by requiring it and passing the ngModule
  // explicitly
  require('./routes')(ngModule);
};
