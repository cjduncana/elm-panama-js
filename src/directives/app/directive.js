'use strict';

module.exports = function(ngModule) {
  ngModule.directive('app', () => {
    return {
      restrict: 'E',
      template: require('./template.html')
    };
  });
};
