var http = require("http"),
    util = require("util"),
    io = require("./socket.io/"),
    sys = require("sys"),
    redis  = require("./node_redis/"),
    redisClient = redis.createClient(),
    subscribeRedisClient = redis.createClient();

var send404 = function(res){ 
    res.writeHead(404, {"Content-Type": "text/plain"}); 
    res.end("404 Not Found"); 
};

var port = 8080;
server = http.createServer(function(req, res) {
    send404(res);
});
server.listen(port);
console.log("Server started on port " + port);

var socket = io.listen(server);

var eachSession = function(key, callback) {
console.log(key);
    var sessionsKey = key + ":sessions";
    redisClient.smembers(sessionsKey, function(err, replies) {
        if (replies.forEach) {
            replies.forEach(function(sessionId) {
                var client = socket.clients[sessionId];
                if (client) {
                    callback.call(client, client);
                } else {
                    redisClient.srem(sessionsKey, sessionId);
                }
            });
        } else {
            console.log("!replies.forEach: " + util.inspect(replies));
        }
    });
};
var firstKey = function(obj) {
    for (var k in obj) {
        if (obj.hasOwnProperty(k)) { return k; }
    }
};

/**
 * CHAT
 */
/*
 * Connect to events from client
 *
 * Events:
 *  - authenticate
 *    message format: { type: "chat.authenticate", chatRoom: <id>, userId: <userId>, token: <token> }
 */
socket.on('connection', function(client) {
    client.on("message", function(message) {
        if (message.type.search("^chat\\.") === 0) {
            // on authenticate
            if (message.type === "chat.authenticate") {
                var chatRoom = message.data.chatRoom,
                    userId = message.data.userId,
                    token = message.data.token;
                var userAuthenticationKey = "chat:" + chatRoom + ":users:" + userId + ":token:" + token,
                    chatSessionsKey = "chat:" + chatRoom + ":sessions",
                    chatPresenceChannel = "chat:" + chatRoom + ":presence";
                redisClient.exists(userAuthenticationKey, function(err, resp) {
                    if (resp) {
                        console.log("User authenticated for chat: " + userId + " sessionId: " + client.sessionId);
                        client.send({ type: "chat.authentication", status: "OK" });
                        redisClient.sadd(chatSessionsKey, client.sessionId);
                        redisClient.publish(chatPresenceChannel, userId + ":enter");

                        client.on("disconnect", function() {
                            redisClient.srem(chatSessionsKey, client.sessionId);
                            redisClient.publish(chatPresenceChannel, userId + ":exit");
                        });
                    } else {
                        console.log("User invalid for chat: " + userId);
                        client.send({ type: "chat.authentication", status: "error", text: "Invalid id or token" });
                    }
                });
            }
        }
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
        var chatId = channel.split(":")[1];

        // on presence
        switch (pattern) {
        case "chat:*:presence": (function() {
                // Message format: user:enter|exit
                var presence = pmessage.match(/([^:]+):(enter|exit)/),
                    userId = presence[1],
                    action = presence[2];

                console.log("Presence: user " + userId + " " + action + " chat " + chatId);
                eachSession("chat:" + chatId, function(client) {
                    client.send({ type: "chat.presence", action: action, user: userId });
                });
            })();
            break;
        case "chat:*:message": (function() {
                // Message format: user:time:messageId:messageText
                var message = pmessage.match(/([^:]+):([^:]+):([^:]+):(.*)/),
                    userId = message[1],
                    time = message[2],
                    messageId = message[3],
                    messageText = message[4];

                console.log("Message from user " + userId + " on chat " + chatId);
                eachSession("chat:" + chatId, function(client) {
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

/**
 * SUPERVISION SESSION
 */
/*
 * Events:
 *  - authenticate
 *    message format: { type: "supervision.authenticate", supervision: <id>, userId: <userId>, token: <token> }
 */
socket.on("connection", function(client) {
    client.on("message", function(message){
        if (message.type.search("^supervision\\.") === 0) {
            // on authenticate
            if (message.type === "supervision.authenticate") {
                var supervision = message.data.supervision,
                    userId = message.data.userId,
                    token = message.data.token;
                var userAuthenticationKey = "supervision:" + supervision + ":users:" + userId + ":token:" + token,
                    supervisionSessionsKey = "supervision:" + supervision + ":sessions";
                redisClient.exists(userAuthenticationKey, function(err, resp) {
                    if (resp) {
                        console.log("User authenticated for supervision: " + userId + " sessionId: " + client.sessionId);
                        client.send({ type: "supervision.authentication", status: "OK" });
                        redisClient.sadd(supervisionSessionsKey, client.sessionId);

                        client.on("disconnect", function() {
                            redisClient.srem("supervision:" + supervision + ":sessions", client.sessionId);
                        });
                    } else {
                        console.log("User invalid for supervision: " + userId);
                        client.send({ type: "supervision.authentication", status: "error", text: "Invalid id or token" });
                    }
                });
            }
        }
    });
});
subscribeRedisClient.on("pmessage", function(pattern, channel, pmessage) {
    if (pattern === "supervision:*") {
        var decodedMessage = JSON.parse(pmessage);
        decodedMessage.type = "supervision." + firstKey(decodedMessage);
        console.log("pmessage: " + decodedMessage.type);
        eachSession(channel, function(client) {
            console.log("sending message to client " + client.sessionId);
            client.send(decodedMessage);
        });
    }
});
subscribeRedisClient.psubscribe("supervision:*");

