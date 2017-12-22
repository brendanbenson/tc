'use strict';

require('./index.html');

var Elm = require('./Main.elm');
var mountNode = document.getElementById('main');

var app = Elm.Main.embed(mountNode);

var ActionCable = require('actioncable');

var socketConnected = false;

app.ports.subscribeToTextMessages.subscribe(function () {
    if (!socketConnected) {
        connectAndReconnect();
    }
});

function connectAndReconnect() {
    console.log('Connecting...');

    socketConnected = true;

    var cable = ActionCable.createConsumer('ws://localhost:3000/cable');

    cable.subscriptions.create('TextMessagesChannel', {
        received: function (data) {
            app.ports.receiveTextMessages.send(JSON.stringify(data));
        },

        connected: function () {
            console.log('Connected to the websocket');
            app.ports.connectedToTextMessages.send(true);
        },

        disconnected: function () {
            console.log('Disconnected');
            socketConnected = false;
            app.ports.connectedToTextMessages.send(false);
        },

        rejected: function () {
            console.log('The server rejected the connection');
        }
    });
}

var ding = require('./sounds/ding.mp3');

app.ports.ding.subscribe(function () {
    var audio = new Audio(ding);
    audio.play();
});

require('./style/base.scss');
require('font-awesome-webpack');