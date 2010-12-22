var http = require("http"),
    util = require("util"),
    io = require("./socket.io/"),
    sys = require("sys"),
    redis  = require("./node_redis/"),
    redisClient = redis.createClient(),
    subscribeRedisClient = redis.createClient();

var port = 8080;
server = http.createServer(function(req, res) {
    send404(res);
});
server.listen(port);
console.log("Server started on port " + port);

var socket = io.listen(server);
socket.on('connection', function(client) {
    client.on("message", function(message) {
        if (message.type === "chat.authenticate") {
            redisClient.exists("users:" + message.data.userId + ":token:" + message.data.token, function(err, resp) {
                if (resp) {
                    console.log("User authenticated: " + message.data.userId + " sessionId: " + client.sessionId);
                    client.send({ type: "chat.authentication", status: "OK" });
                    redisClient.mset(
                        "sessions:" + client.sessionId + ":chat", message.data.chatRoom,
                        "sessions:" + client.sessionId + ":user", message.data.userId
                    );
                    redisClient.sadd("chat:" + message.data.chatRoom + ":sessions", client.sessionId);
                    redisClient.publish("chat:" + message.data.chatRoom + ":presence", message.data.userId + ":enter");
                } else {
                    console.log("User invalid: " + message.data.userId);
                    client.send({ type: "chat.authentication", status: "error", text: "Invalid id or token" });
                }
            });
        }
    });
    client.on('disconnect', function() {
        redisClient.mget("sessions:" + client.sessionId + ":user", "sessions:" + client.sessionId + ":chat", function(err, results) {
            var userId = results[0],
                chatId = results[1];
            redisClient.srem("chat:" + chatId + ":sessions", client.sessionId);
            redisClient.publish("chat:" + chatId + ":presence", userId + ":exit");
        });
    });
});

subscribeRedisClient.on("pmessage", function(pattern, channel, pmessage) {
    var chatId = channel.split(":")[1],
        userId;
    var presence, action;
    var message, time, messageId, messageText;
    if (pattern === "chat:*:presence") {
        presence = pmessage.split(":", 2); // user:enter|exit
        userId = presence[0];
        action = presence[1];

        console.log("Presence: user " + userId + " " + action + " chat " + chatId);
        redisClient.smembers("chat:" + chatId + ":sessions", function(err, replies) {
            if (replies.forEach) {
                replies.forEach(function(sessionId, index) {
                    var client = socket.clients[sessionId];
                    if (client) {
                        client.send({ type: "chat.presence", action: action, user: userId });
                    } else { //cleanup
                        redisClient.srem("chat:" + chatId + ":sessions", sessionId);
                    }
                });
            } else {
                console.log("!replies.forEach");
                console.log(replies);
            }
        });
    } else if (pattern === "chat:*:message") {
        message = pmessage.split(":", 4); // user:time:id:text
        userId = message[0];
        time = message[1];
        messageId = message[2];
        messageText = message[3];

        console.log("Message from user " + userId + " on chat " + chatId);
        redisClient.smembers("chat:" + chatId + ":sessions", function(err, replies) {
            if (replies.forEach) {
                replies.forEach(function(sessionId, index) {
                    var client = socket.clients[sessionId];
                    if (client) {
                        client.send({ type: "chat.message", user: userId, timestamp: time, id: messageId, content: messageText });
                    } else {
                        redisClient.srem("chat:" + chatId + ":sessions", sessionId);
                    }
                });
            } else {
                console.log("!replies.forEach");
                console.log(replies);
            }
        });
    }
});
subscribeRedisClient.psubscribe("chat:*:presence", "chat:*:message");
