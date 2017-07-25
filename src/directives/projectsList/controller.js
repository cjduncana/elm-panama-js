'use strict';

module.exports = function(ngModule) {
  ngModule.controller('projectsListCtrl', projectsListCtrl);

  projectsListCtrl.$inject = ['ProjectService'];

  function projectsListCtrl(ProjectService) {
    this.items = [];

    ProjectService.list()
      .then((items) => {
        this.items = items;
      });
  }
};
