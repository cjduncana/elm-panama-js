'use strict';

module.exports = function(ngModule) {
  ngModule.controller('projectsDetailCtrl', projectsDetailCtrl);

  projectsDetailCtrl.$inject = ['$stateParams', 'ProjectService'];

  function projectsDetailCtrl($stateParams, ProjectService) {
    ProjectService.detail($stateParams.id)
      .then((result) => {
        this.item = result;
      });
  }
};
