'use strict';

require('bootstrap/less/bootstrap.less');
require('font-awesome/less/font-awesome.less');
require('open-sans-fontface/open-sans.less');
require('animate.css/animate.css');
require('./assets/less/style.less');

const Elm = require('./elm/Main.elm');

Elm.Main.fullscreen({ token: TOKEN.join('') });
