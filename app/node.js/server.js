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

subscribeRedisClient.on("pmessage", function(pattern, channel, pmessage) {
    if (pattern === "chat:*:presence") {
        var chatId = channel.split(":")[1],
            presence = pmessage.split(":", 2), // user:enter|exit
            userId = presence[0],
            action = presence[1];

        console.log("Presence: user " + userId + " " + action + " chat " + chatId);
        redisClient.smembers("chat:" + chatId + ":sessions", function(err, replies) {
            replies.forEach(function(sessionId, index) {
                var client = socket.clients[sessionId];
                if (client) {
                    client.send({ type: "presence", action: action, user: userId });
                } else { //cleanup
                    redisClient.srem("chat:" + chatId + ":sessions", sessionId);
                }
            });
        });
    } else if (pattern === "chat:*:message") {
        var chatId = channel.split(":")[1],
            message = pmessage.split(":", 3), // user:time:text
            userId = message[0],
            time = message[1],
            messageText = message[2];

        console.log("Message from user " + userId + " on chat " + chatId);
        redisClient.smember("chat:" + chatId + ":sessions", function(err, replies) {
            replies.forEach(function(sessionId, index) {
                var client = socket.clients[sessionId];
                if (client) {
                    client.send({ type: "message", user: userId, time: time, text: messageText });
                } else {
                    redisClient.sremp("chat:" + chatId + ":sessions", sessionId);
                }
            });
        });
    }
});
subscribeRedisClient.psubscribe("chat:*:presence");

var socket = io.listen(server);
socket.on('connection', function(client) {
    client.on("message", function(message) {
        if (message.hasOwnProperty("userId") && message.hasOwnProperty("token")) {
            redisClient.exists("users:" + message.userId + ":token:" + message.token, function(err, resp) {
                //if (resp) {
                    console.log("User authenticated: " + message.userId + " sessionId: " + client.sessionId);
                    client.send({ status: "OK" });
                    redisClient.mset(
                        "sessions:" + client.sessionId + ":chat", message.chatRoom,
                        "sessions:" + client.sessionId + ":user", message.userId
                    );
                    redisClient.sadd("chat:" + message.chatRoom + ":sessions", client.sessionId);
                    redisClient.publish("chat:" + message.chatRoom + ":presence", message.userId + ":enter");
                //} else {
                    //console.log("User invalid: " + message.id);
                    //client.send({ status: "error", text: "Invalid id or token" });
                //}
            });
        } else {
            console.log("Invalid authentication message");
            client.send("Invalid autnentication message");
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
console.log("Server started on port " + port);
