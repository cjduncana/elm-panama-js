'use strict';

module.exports = function(ngModule) {
  require('./app')(ngModule);
  require('./projectsDetail')(ngModule);
  require('./projectsItem')(ngModule);
  require('./projectsList')(ngModule);
};
