'use strict';

module.exports = function(ngModule) {
  ngModule.directive('projectsItem', () => {
    return {
      restrict: 'E',
      scope: {
        item: '='
      },
      template: require('./template.html'),
      controller: function() {},
      controllerAs: 'vm',
      bindToController: true
    };
  });
};
