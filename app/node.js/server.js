var http = require("http"),
    util = require("util"),
    io = require("./socket.io/"),
    sys = require("sys"),
    redis  = require("./node_redis/"),
    redisClient = redis.createClient(),
    subscribeRedisClient = redis.createClient();

var send404 = function(res){ 
    res.writeHead(404); 
    res.end("404 Not Found"); 
};

var port = 8080;
server = http.createServer(function(req, res) {
    send404(res);
});
server.listen(port);
console.log("Server started on port " + port);

// Chat
var socket = io.listen(server);
socket.on('connection', function(client) {
    client.on("message", function(message) {
        if (message.type.search("^chat\\.") === 0) {
            // on authenticate
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
        }
    });
    client.on('disconnect', function() {
        redisClient.mget("sessions:" + client.sessionId + ":user", "sessions:" + client.sessionId + ":chat", function(err, results) {
            if (results[0] !== null && results[1] !== null) {
                var userId = results[0],
                    chatId = results[1];
                redisClient.srem("chat:" + chatId + ":sessions", client.sessionId);
                redisClient.publish("chat:" + chatId + ":presence", userId + ":exit");
            }
        });
    });
});

/*
 * Channel: chat:<chatId>:presence
 * Message: <user>:enter
 *          <user>:exit
 *
 * Channel: chat:<chatId>:message
 * Message: <user>:<time>:<messageId>:<mesageText>
 */
subscribeRedisClient.on("pmessage", function(pattern, channel, pmessage) {
    if (pattern.search("^chat:") === 0) {

        var eachSession = function(chatId, callback) {
            var chatKey = "chat:" + chatId + ":sessions";
            redisClient.smembers(chatKey, function(err, replies) {
                // this should not return false, but it does
                if (replies.forEach) {
                    replies.forEach(function(sessionId) {
                        var client = socket.clients[sessionId];
                        if (client) {
                            callback.call({}, client, sessionId);
                        } else {
                            // Cleanup obsolate session in chat
                            redisClient.srem(chatKey, sessionId);
                        }
                    });
                } else {
                    console.log("!replies.forEach: " + util.inspect(replies));
                }
            });
        };

        var chatId = channel.split(":")[1];

        // on presence
        switch (pattern) {
        case "chat:*:presence": (function() {
                // Message format: user:enter|exit
                var presence = pmessage.split(":", 2),
                    userId = presence[0],
                    action = presence[1];

                console.log("Presence: user " + userId + " " + action + " chat " + chatId);
                eachSession(chatId, function(client, sessionId) {
                    client.send({ type: "chat.presence", action: action, user: userId });
                });
            })();
            break;
        case "chat:*:message": (function() {
                // Message format: user:time:messageId:messageText
                var message = pmessage.split(":", 4),
                    userId = message[0],
                    time = message[1],
                    messageId = message[2],
                    messageText = message[3];

                console.log("Message from user " + userId + " on chat " + chatId);
                eachSession(chatId, function(client, sessionId) {
                    client.send({ type: "chat.message", user: userId, timestamp: time, id: messageId, content: messageText });
                });
            })();
            break;
        default:
            console.log("unknown channel: " + channel);
            break;
        }
    }
});
subscribeRedisClient.psubscribe("chat:*:presence", "chat:*:message");
