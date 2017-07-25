'use strict';

module.exports = function(ngModule) {
  ngModule.directive('projectsList', () => {
    return {
      restrict: 'E',
      template: require('./template.html'),
      controller: 'projectsListCtrl',
      controllerAs: 'vm'
    };
  });
};
