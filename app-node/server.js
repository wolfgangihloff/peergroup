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

var ChatMembershipMessage = {
    enter:  function(userId) {
                return { chat_membership: { status: "enter", user_id: userId } }
            },
    exit:   function(userId) {
                return { chat_membership: { status: "exit", user_id: userId } }
            }
};
var Chat = {
    authenticationResponse: {
        ok:     { type: "chat.authentication", status: "OK" },
        fail:   { type: "chat.authentication", status: "error", text: "Invalid ID or token"}
    },
    userAuthenticationKey: function(chatRoomId, token) { return "chat:"+chatRoomId+":token:"+token; },
    sessionsKey: function(chatRoomId) { return "chat:"+chatRoomId+":sessions"; }
};
var Channels = {
    chat: function(chatRoomId) { return "chat:"+chatRoomId; }
};
    

/**
 * CHAT
 *  - authenticate
 *    message format: { type: "chat.authenticate", chatRoomId: <id>, userId: <userId>, token: <token> }
 */
/*
 * SUPERVISION SESSION
 *  - authenticate
 *    message format: { type: "supervision.authenticate", supervision: <id>, userId: <userId>, token: <token> }
 */
socket.on('connection', function(client) {
    client.on("message", function(message) {
        if (message.type.search(/^chat\./) === 0) {
            // on authenticate
            if (message.type === "chat.authenticate") {
                var chatRoomId = message.data.chatRoomId,
                    token = message.data.token;

                redisClient.get(Chat.userAuthenticationKey(chatRoomId, token), function(err, resp) {
                    var chatSessionsKey = Chat.sessionsKey(chatRoomId),
                        chatChannel = Channels.chat(chatRoomId),
                        userId = resp;

                    if (userId) {
                        console.log("User:"+userId+" authenticated for chat:"+chatRoomId+" sessionId:"+client.sessionId);
                        client.send(Chat.authenticationResponse.ok);

                        // Add user to chat subscribers
                        redisClient.sadd(chatSessionsKey, client.sessionId, function(err, resp) {
                            redisClient.publish(chatChannel, JSON.stringify(ChatMembershipMessage.enter(userId)));
                        });

                        client.on("disconnect", function() {
                            // Remove user from chat subscribers
                            redisClient.srem(chatSessionsKey, client.sessionId, function(err, resp) {
                                redisClient.publish(chatChannel, JSON.stringify(ChatMembershipMessage.exit(userId)));
                            });
                        });
                    } else {
                        console.log("Invalid token:"+token+" for chat:"+chatRoomId);
                        client.send(Chat.authenticationResponse.fail);
                    }
                });
            }
        }
        if (message.type.search(/^supervision\./) === 0) {
            // on authenticate
            if (message.type === "supervision.authenticate") {
                var supervisionId = message.data.supervision,
                    userId = message.data.userId,
                    token = message.data.token;
                var userAuthenticationKey = "supervision:" + supervisionId + ":users:" + userId + ":token:" + token,
                    supervisionSessionsKey = "supervision:" + supervisionId + ":sessions";
                redisClient.exists(userAuthenticationKey, function(err, resp) {
                    if (resp) {
                        console.log("User authenticated for supervision: " + userId + " sessionId: " + client.sessionId);
                        client.send({ type: "supervision.authentication", status: "OK" });
                        redisClient.sadd(supervisionSessionsKey, client.sessionId);

                        client.on("disconnect", function() {
                            redisClient.srem("supervision:" + supervisionId + ":sessions", client.sessionId);
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
    var decodedMessage = JSON.parse(pmessage);
    var rootKey = firstKey(decodedMessage);
    var type;
    switch (pattern) {
    case "supervision:*":
        type = "supervision";
        break;
    case "chat:*":
        type = "chat";
        break;
    default:
        console.log("Unknown message type: " + rootKey);
        return;
    }
    decodedMessage.type = type + "." + rootKey
    console.log("pmessage: " + decodedMessage.type);
    eachSession(channel, function(client) {
        console.log("sending message to client " + client.sessionId);
        client.send(decodedMessage);
    });
});
subscribeRedisClient.psubscribe("supervision:*");
subscribeRedisClient.psubscribe("chat:*");

