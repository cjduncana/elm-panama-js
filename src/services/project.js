'use strict';

const elm = require('../elm/Main.elm').Main;

module.exports = function(ngModule) {

  ngModule.service('ProjectService', ProjectService);

  ProjectService.$inject = ['$http', '$q'];

  function ProjectService($http, $q) {

    const worker = elm.worker({ token: TOKEN.join('') });

    function detail(repo) {
      worker.ports.getProject.send(repo);

      return $q((resolve) => worker.ports.sendProject.subscribe(resolve));
    }

    function list() {
      worker.ports.getProjects.send();

      return $q((resolve) => worker.ports.sendProjects.subscribe(resolve));
    }

    return {
      detail,
      list
    };
  }
};
