'use strict';

require('./index.html');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');

var app = Elm.Main.embed(mountNode);

require('./stomp');
var SockJS = require('./sockjs');

var socketUrl = '/realtime';
var ws = new SockJS(socketUrl);
var client = Stomp.over(ws);

app.ports.subscribeToTextMessages.subscribe(function () {
    connectAndReconnect(onConnect);
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

require('./style/base.scss');
require('font-awesome-webpack');