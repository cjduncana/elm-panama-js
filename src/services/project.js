'use strict';

const elm = require('../elm/Main.elm').Main;

module.exports = function(ngModule) {

  ngModule.service('ProjectService', ProjectService);

  ProjectService.$inject = ['$http', '$q'];

  function ProjectService($http, $q) {

    const worker = elm.worker({ token: TOKEN.join('') });

    function detail(repo) {
      const token = '?access_token=' + TOKEN.join('');

      const url = 'https://api.github.com/repos/' + repo + token;

      const data = {};

      return $http.get(url)
        .then((result) => {
          data.detail = result.data;

          return $q.all([
            $http.get(result.data.events_url + token),
            $http.get(result.data.contributors_url + token),
            $http.get(result.data.url + '/issues' + token),
            $http.get(result.data.url + '/labels' + token),
            $http.get(result.data.url + '/commits' + token)
          ]);
        })
        .then(([events, contributors, issues, labels, commits]) => {
          data.events = events.data;
          data.contributors = contributors.data;
          data.issues = issues.data;
          data.labels = labels.data;
          data.commits = commits.data;

          return data;
        });
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
