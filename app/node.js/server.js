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

var socket = io.listen(server);

/**
 * CHAT
 */
/*
 * Connect to events from client
 *
 * Events:
 *  - authenticate
 *    message format: { type: "chat.authenticate", chatRoom: <id>, userId: <userId> }
 */
socket.on('connection', function(client) {
    client.on("message", function(message) {
        if (message.type.search("^chat\\.") === 0) {
            // on authenticate
            if (message.type === "chat.authenticate") {
                var chatRoom = message.data.chatRoom,
                    userId = message.data.userId;
                var userAuthenticationKey = "chat:" + chatRoom + ":users:" + message.data.userId + ":token:" + message.data.token,
                    sessionChatKey = "sessions:" + client.sessionId + ":chat",
                    chatSessionsKey = "chat:" + chatRoom + ":sessions";
                redisClient.exists(userAuthenticationKey, function(err, resp) {
                    if (resp) {
                        console.log("User authenticated: " + userId + " sessionId: " + client.sessionId);
                        client.send({ type: "chat.authentication", status: "OK" });
                        redisClient.hmset(sessionChatKey, "id", chatRoom, "user", userId);
                        redisClient.sadd(chatSessionsKey, client.sessionId);
                        redisClient.publish("chat:" + chatRoom + ":presence", userId + ":enter");
                    } else {
                        console.log("User invalid: " + userId);
                        client.send({ type: "chat.authentication", status: "error", text: "Invalid id or token" });
                    }
                });
            }
        }
    });
    client.on('disconnect', function() {
        var sessionChatKey = "sessions:" + client.sessionId + ":chat";
        redisClient.hmget(sessionChatKey, "id", "user", function(err, results) {
            if (results[0] !== null && results[1] !== null) {
                var chatId = results[0],
                    userId = results[1];
                redisClient.srem("chat:" + chatId + ":sessions", client.sessionId);
                redisClient.publish("chat:" + chatId + ":presence", userId + ":exit");
                redisClient.del(sessionChatKey);
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
