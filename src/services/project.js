'use strict';

module.exports = function(ngModule) {

  ngModule.service('ProjectService', ProjectService);

  ProjectService.$inject = ['$http', '$q'];

  function ProjectService($http, $q) {

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

    function getDate() {
      const date = new Date();
      date.setDate(date.getDate() - 7);
      const year = date.getFullYear();
      const month = `0${date.getMonth() + 1}`.slice(-2);
      const day = `0${date.getDate()}`.slice(-2);
      return `${year}-${month}-${day}`;
    }

    function list() {
      const date = getDate();
      const url = 'https://api.github.com/search/repositories' +
        `?q=created:>${date}` +
        '&sort=stars' +
        '&order=desc' +
        `&access_token=${TOKEN.join('')}`;

      return $http.get(url)
        .then((result) => result.data.items);
    }

    return {
      detail,
      list
    };
  }
};
