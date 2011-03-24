var http = require("http"),
    util = require("util"),
    io = require("./socket.io/"),
    sys = require("sys"),
    redis  = require("./node_redis/");

/*
 * Redis connection address
 */
var redisPort = process.env["REDIS_PORT"], // || default
    redisHost = process.env["REDIS_HOST"], // || default
    redisDb =   process.env["REDIS_DB"] || 0;
/*
 * Server port
 */
var serverPort = process.env["NODE_PORT"]  || 8080;

/*
 * Send 404 Not Found
 */
var send404 = function(res){ 
    res.writeHead(404, {"Content-Type": "text/plain"}); 
    res.end("404 Not Found"); 
};

/*
 * Call callback for each session from Redis set
 */
var eachSession = function(key, callback) {
    //console.log(key);
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

/*
 * Return first (probably random) key
 * Used to retrieve root key from deserialized JSON messages
 */
var firstKey = function(obj) {
    for (var k in obj) {
        if (obj.hasOwnProperty(k)) { return k; }
    }
};

var Chat = function(id, token) {
    this.userAuthenticationKey = "chat:"+id+":token:"+token;
    this.sessionsKey = "chat:"+id+":sessions";
    this.channel = "chat:"+id;
};
Chat.prototype.authenticationSuccessedMessage = { type: "chat.authentication", status: "OK" };
Chat.prototype.authenticationFailedMessage = { type: "chat.authentication", status: "error", text: "Invalid ID or token" };

var ChatMembership = function(userId) {
    this.enterMessage = { chat_membership: { status: "enter", user_id: userId } };
    this.exitMessage =  { chat_membership: { status: "exit",  user_id: userId } };
};

var server = http.createServer(function(req, res) {
    send404(res);
});
server.listen(serverPort);
var socket = io.listen(server);
util.log("Server started on port " + serverPort);

var redisClient = redis.createClient(redisPort, redisHost),
    subscribeRedisClient = redis.createClient(redisPort, redisHost);

var initializeClientConnections = function() {
    socket.on('connection', function(client) {
        client.on("message", function(message) {
            /**
             * CHAT
             *  - authenticate
             *    message format: { type: "chat.authenticate", chatRoomId: <id>, userId: <userId>, token: <token> }
             */
            if (message.type.search(/^chat\./) === 0) {
                // on authenticate
                if (message.type === "chat.authenticate") {
                    var chatRoomId = message.data.chatRoomId,
                        token = message.data.token,
                        chat = new Chat(chatRoomId, token);

                    redisClient.get(chat.userAuthenticationKey, function(err, userId) {
                        if (userId) {
                            var chatMembership = new ChatMembership(userId);

                            util.log("[chat] User:"+userId+" authenticated for chat:"+chatRoomId+" sessionId:"+client.sessionId);
                            client.send(chat.authenticationSuccessedMessage);

                            // Add user to chat subscribers
                            redisClient.sadd(chat.sessionsKey, client.sessionId, function(err, resp) {
                                redisClient.publish(chat.channel, JSON.stringify(chatMembership.enterMessage));
                            });

                            client.on("disconnect", function() {
                                // Remove user from chat subscribers
                                redisClient.srem(chat.sessionsKey, client.sessionId, function(err, resp) {
                                    redisClient.publish(chat.channel, JSON.stringify(chatMembership.exitMessage));
                                });
                            });
                        } else {
                            util.log("[chat] Invalid token:"+token+" for chat:"+chatRoomId);
                            client.send(chat.authenticationFailedMessage);
                        }
                    });
                }
            }
            /*
             * SUPERVISION SESSION
             *  - authenticate
             *    message format: { type: "supervision.authenticate", supervision: <id>, userId: <userId>, token: <token> }
             */
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
}

var subscribeToChannels = function() {
    subscribeRedisClient.on("pmessage", function(pattern, channel, pmessage) {
        var decodedMessage = JSON.parse(pmessage),
            rootKey = firstKey(decodedMessage),
            type;
        switch (pattern) {
        case "supervision:*":
            type = "supervision";
            break;
        case "chat:*":
            type = "chat";
            break;
        default:
            util.log("Unknown message type: " + rootKey);
            return;
        }
        decodedMessage.type = type + "." + rootKey
        util.log("["+type+"] pmessage: " + decodedMessage.type);
        eachSession(channel, function(client) {
            util.log("["+type+"] Sending message to client " + client.sessionId);
            client.send(decodedMessage);
        });
    });
    subscribeRedisClient.psubscribe("supervision:*");
    subscribeRedisClient.psubscribe("chat:*");
};

subscribeToChannels();

// Only select DB for redisClient, as subscribeRedisClient can work without selecting database,
// pub/sub works across db's
redisClient.select(redisDb, function(err, resp) {
    if (!err) {
        util.log("Initializing client connection support")
        initializeClientConnections();
    } else {
        util.log("[ERROR] Could not select redisDb: "+redisDb+", exiting");
        process.exit(-1);
    }
});

