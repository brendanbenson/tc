'use strict';

require('./index.html');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');

var AUTH_TOKEN_KEY = 'authToken', OPEN_THREADS_KEY = 'openThreads', BASE_URL = 'http://localhost:8080';

var app = Elm.Main.embed(mountNode, {
    authToken: localStorage.getItem(AUTH_TOKEN_KEY),
    baseUrl: BASE_URL
});

require('./stomp');
var SockJS = require('./sockjs');

var socketUrl = BASE_URL + '/realtime';
var ws = new SockJS(socketUrl);
var client = Stomp.over(ws);

app.ports.subscribeToTextMessages.subscribe(function () {
    connectAndReconnect(onConnect);
});

app.ports.unsubscribeFromTextMessages.subscribe(function () {
    try {
        client.disconnect();
    } catch (e) {
        // Do nothing
    }
});

var onConnect = function () {
    client.subscribe('/text-messages', function (textMessageResponse) {
        app.ports.receiveTextMessages.send(textMessageResponse.body);
    });
};

function connectAndReconnect(successCallback) {
    ws = new SockJS(socketUrl);
    client = Stomp.over(ws);
    client.connect({}, function (frame) {
        successCallback();
    }, function () {
        setTimeout(function () {
            connectAndReconnect(successCallback);
        }, 10000);
    });
}


app.ports.saveAuthToken.subscribe(function (authToken) {
    if (authToken === null) {
        localStorage.removeItem(AUTH_TOKEN_KEY);
    } else {
        localStorage.setItem(AUTH_TOKEN_KEY, authToken);
    }
});

require('./style/base.scss');
require('font-awesome-webpack');