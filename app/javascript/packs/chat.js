import Elm from '../chat/Main';
import ding from '../sounds/ding.mp3';

document.addEventListener('DOMContentLoaded', () => {
  const target = document.createElement('div');

  document.body.appendChild(target);
  let app = Elm.Main.embed(target);

  let socketConnected = false;

  app.ports.subscribeToTextMessages.subscribe(function () {
    if (!socketConnected) {
      connectAndReconnect();
    }
  });

  function connectAndReconnect() {
    socketConnected = true;

    let cable = ActionCable.createConsumer('/cable');

    cable.subscriptions.create('TextMessagesChannel', {
      received: function (data) {
        app.ports.receiveTextMessages.send(JSON.stringify(data));
      },

      connected: function () {
        app.ports.connectedToTextMessages.send(true);
      },

      disconnected: function () {
        socketConnected = false;
        app.ports.connectedToTextMessages.send(false);
      },

      rejected: function () {
      }
    });
  }

  app.ports.ding.subscribe(function () {
    let audio = new Audio(ding);
    audio.play();
  });
});

require('../src/chat.scss');
require('font-awesome-webpack');