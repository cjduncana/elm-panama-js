'use strict';

require('bootstrap/less/bootstrap.less');
require('font-awesome/less/font-awesome.less');
require('open-sans-fontface/open-sans.less');
require('animate.css/animate.css');
require('./assets/less/style.less');

const angular = require('angular');

require('angular-ui-router');

const ngModule = angular.module('app', [
  'ui.router'
]);

// Load configs
require('./config')(ngModule);

// Load directives
require('./directives')(ngModule);

// Load services
require('./services')(ngModule);
