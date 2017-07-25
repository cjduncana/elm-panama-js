'use strict';

module.exports = (ngModule) => {
  ngModule.config(router);

  router.$inject = ['$stateProvider', '$urlRouterProvider'];

  function router($stateProvider, $urlRouterProvider) {
    $urlRouterProvider.otherwise('/');

    $stateProvider
      .state('home', {
        url: '/',
        template: '<projects-list></projects-list>'
      })
      .state('detail', {
        url: '/:id',
        template: '<projects-detail></projects-detail>'
      });
  };
};
