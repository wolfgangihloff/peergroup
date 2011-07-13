var http = require("http"),
    util = require("util"),
    fs = require("fs"),
    io = require("./socket.io/"),
    sys = require("sys"),
    redis = require("./node_redis/"),
    _und = require("./underscore/");

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
 * Call callback for each session from Redis hash
 */
var eachSession = function(key, callback) {
    var sessionsKey = key + ":sessions";
    redisClient.hgetall(sessionsKey, function(err, replies) {
        _und.each(replies, function(sessionId, userId) {
            var client = socket.clients[sessionId];
            if (client) {
                callback.call(client, client);
            } else {
                redisClient.hdel(sessionsKey, userId);
            }
        });
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

                            util.log("[chat] User:"+userId+" authenticated for chat:"+chatRoomId+" sessionId:"+client.sessionId);
                            client.send(chat.authenticationSuccessedMessage);

                            // Hash of chat session, contains: {userId: sessionId}
                            redisClient.hset(chat.sessionsKey, userId, client.sessionId)

                            redisClient.hkeys(chat.sessionsKey, function(err, resp) {
                                redisClient.publish(chat.channel, JSON.stringify({chat_presence: {user_ids: resp, user_id: userId, status: "enter"}}));
                            });

                            client.on("disconnect", function() {
                                // Remove user from chat session after 20 seconds
                                redisClient.hdel(chat.sessionsKey, userId)

                                setTimeout(function() {
                                    redisClient.hkeys(chat.sessionsKey, function(err, resp) {
                                        if (!_und.include(resp, userId)) {
                                            redisClient.publish(chat.channel, JSON.stringify({chat_presence: {user_ids: resp, user_id: userId, status: "exit"}}));
                                        }
                                    });
                                }, 20000);
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
             *    message format: { type: "supervision.authenticate", supervisionId: <id>, userId: <userId>, token: <token> }
             */
            if (message.type.search(/^supervision\./) === 0) {
                var supervisionId = message.data.supervisionId;
                // on authenticate
                if (message.type === "supervision.authenticate") {
                    var userId = message.data.userId,
                        token = message.data.token;
                    var userAuthenticationKey = "supervision:" + supervisionId + ":users:" + userId + ":token:" + token,
                        supervisionSessionsKey = "supervision:" + supervisionId + ":sessions";
                    redisClient.exists(userAuthenticationKey, function(err, resp) {
                        if (resp) {
                            console.log("User authenticated for supervision: " + userId + " sessionId: " + client.sessionId);
                            client.send({ type: "supervision.authentication", status: "OK" });
                            redisClient.hset(supervisionSessionsKey, userId, client.sessionId);

                            client.on("disconnect", function() {
                                redisClient.hdel("supervision:" + supervisionId + ":sessions", userId);

                                // remove member from supervision after 20 seconds
                                setTimeout(function() {
                                    redisClient.hkeys(supervisionSessionsKey, function(err, resp) {
                                        if (!_und.include(resp, userId)) {
                                            PGS.request(PGS.supervision_members_path(supervisionId, userId), "DELETE");
                                        }
                                    });
                                }, 20000);
                            });
                        } else {
                            console.log("User invalid for supervision: " + userId);
                            client.send({ type: "supervision.authentication", status: "error", text: "Invalid id or token" });
                        }
                    });
                } else if (message.type === "supervision.member_idle_status") {
                    redisClient.publish("supervision:"+supervisionId, JSON.stringify({idle_status_changed: message.data}));
                }
            }
        });
    });
}

var PGS = {
    //username: "node",

    //password: "secret",

    auth_header: function() {
        return "Basic " + new Buffer(PGS.username + ":" + PGS.password).toString("base64");
    },

    supervision_members_path: function(supervisionId, memberId) {
        return "/node/supervisions/" + supervisionId + "/members/" + memberId;
    },

    request: function(path, method) {
        //var body = JSON.stringify({ "supervision_membership": {"firstname": "Joe", "lastname": "Bloggs"} })
        var options = {
          host: 'localhost',
          port: 3000,
          path: path,
          method: method,
          headers: {"Content-Type": "application/json", "Accept": "application/json", "Authorization": PGS.auth_header()}//, "Content-Length": Buffer.byteLength(body)}
        };

        var req = http.request(options, function(res) {
          console.log('STATUS: ' + res.statusCode);
          res.setEncoding('utf8');
          res.on('data', function (chunk) {
            console.log('BODY: ' + chunk);
          });
        });

        req.on('error', function(e) {
          console.log('problem with request: ' + e.message);
        });

        // write data to request body
        //req.write(body);
        req.end();
    }
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

var pingRedisClient = function(){
    redisClient.ping();
};
setInterval(pingRedisClient, 10000);

fs.readFile('/home/wojtek/Ruby/peergroup/app-node/config.json', 'utf8', function (err, data) {
  if (err) throw err;
  var config = JSON.parse(data);
  PGS.username = config.username;
  PGS.password = config.password;
  console.log(JSON.parse(data));
});
