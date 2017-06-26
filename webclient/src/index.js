'use strict';

// Require index.html so it gets copied to dist
require('./index.html');

// var StompJS = require('./stomp.js');


var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');

var AUTH_TOKEN_KEY = 'authToken', OPEN_THREADS_KEY = 'openThreads';

// .embed() can take an optional second argument. This would be an object describing the data we need to start a program, i.e. a userID or some token
var app = Elm.Main.embed(mountNode, {
    authToken: localStorage.getItem(AUTH_TOKEN_KEY)
});

require('./stomp');
var SockJS = require('./sockjs');

var socket = new SockJS('http://localhost:8080/realtime');
var stompClient = Stomp.over(socket);
var isConnected = false;

app.ports.subscribeToTextMessages.subscribe(function () {
    stompClient.connect({}, function (frame) {
        isConnected = true;
        stompClient.subscribe('/text-messages', function (textMessageResponse) {
            app.ports.receiveTextMessages.send(textMessageResponse.body);
        });
    });
});

app.ports.saveAuthToken.subscribe(function (authToken) {
    localStorage.setItem(AUTH_TOKEN_KEY, authToken);
});

require('./style/base.scss');
require('font-awesome-webpack');