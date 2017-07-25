'use strict';

module.exports = function(ngModule) {
  require('./controller')(ngModule);
  require('./directive')(ngModule);
};
