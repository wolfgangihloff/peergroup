// This module wraps socket connection from Socket.io adding namespace
// for events (namespace "chat" binds to messages with type "chat.*")
//
// constructor: S(socket, namespace)
//
//     var s = S(socket, "chat")
//
// methods:
//  * on(type, callback) - register callback for type event, callback
//    gets full message type (with prefix) and them whole message object
//
//     s.on("presence", function(messageType, message){})
//
//  * onConnect(callback) - callback after successfull connecting to socket
//
//     s.onConnect(function() {})
//
//  * send(type, data) - send message to server, namespace type with prefix
//
//     s.send("authenticate", { user: 10 })
//
// properties:
//  * socket - socket object, in case you want to perform some specific
//    voodoo magic
//  * namespace - prefix
//
// In case of callbacks - insrtance of this module is set as context for
// every callback .
var S = function (socket, namespace) {
    var callbacks = {},
        connectCallbacks = [],
        prefix = function (type) {
            return namespace + "." + type;
        };

    var that = {
        socket: socket,
        namespace: namespace,
        on: function (type, callback) {
            if (!callbacks[prefix(type)]) {
                callbacks[prefix(type)] = [];
            }
            callbacks[prefix(type)].push(callback);
            return this;
        },
        onConnect: function (callback) {
            connectCallbacks.push(callback);
            return this;
        },
        send: function (type, data) {
            socket.send({ type: prefix(type), data: data });
            return this;
        }
    };

    var onMessage = function (message) {
        if (message.type && callbacks[message.type]) {
            _.each(callbacks[message.type], function (callback) {
                callback.call(that, message.type, message);
            });
        }
    };
    var onConnect = function () {
        _.each(connectCallbacks, function (callback) {
            callback.call(that);
        });
    };
    socket.on("message", onMessage);
    socket.on("connect", onConnect);

    return that;
};
