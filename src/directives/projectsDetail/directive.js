'use strict';

module.exports = function(ngModule) {
  ngModule.directive('projectsDetail', () => {
    return {
      restrict: 'E',
      template: require('./template.html'),
      controller: 'projectsDetailCtrl',
      controllerAs: 'vm'
    };
  });
};
