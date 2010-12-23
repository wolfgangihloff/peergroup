(function($){
    $.fn.chatRoom = function() {
        return this.each(function() {
            var $this = $(this),
                $messages = $this.find(".messages");

            $messages.find("time").timeago();

            var onMessage = function(event, message) {
                var id = message.id || -1,
                    user = message.user || "(unknown)",
                    date = message.date || new Date(),
                    content = message.content || "";

                var newMessage = $("<li>", { "class": "chat_message", id: id }).
                    append($("<span>", { "class": "user", text: user })).
                    append(" ").
                    append($("<time>", { datetime: date.toISOString() }).append(date).timeago()).
                    append(" : ").
                    append($("<span>", { "class": "content", text: content }));
                $messages.append(newMessage);
            };
            var onSystemMessage = function(event, message) {
                var text = message.text || "",
                    date = message.date || new Date();

                var newMessage = $("<li>", { "class": "system_chat_message" }).
                    append($("<time>", { datetime: date.toISOString() }).append(date).timeago()).
                    append(" ").
                    append($("<span>", { "class": "content", text: text }));
                $messages.append(newMessage);
            };

            $this.bind({
                "message": onMessage,
                "systemMessage": onSystemMessage
            });


        });
    };
})(jQuery);

jQuery(function($) {
    var S = function(socket, namespace) {
        var callbacks = {},
            connectCallbacks = [],
            prefix = function(type) { return namespace + "." + type; };

        var that = {
            socket: socket,
            namespace: namespace,
            on: function(type, callback) {
                if (!callbacks[prefix(type)]) { callbacks[prefix(type)] = []; }
                callbacks[prefix(type)].push(callback);
                return this;
            },
            onConnect: function(callback) {
                connectCallbacks.push(callback);
                return this;
            },
            send: function(type, data) {
                socket.send({ type: prefix(type), data: data });
                return this;
            }
        };

        var onMessage = function(message) {
            if (message.type && callbacks[message.type]) {
                _.each(callbacks[message.type], function(callback) {
                    callback.call(that, message.type, message);
                });
            }
        };
        var onConnect = function() {
            _.each(connectCallbacks, function(callback) {
                callback.call(that);
            });
        };
        socket.on("message", onMessage);
        socket.on("connect", onConnect);

        return that;
    };

    $(".chat_room").each(function(i, element) {
        var $chatRoom = $(this);
        $chatRoom.chatRoom();

        var $form = $chatRoom.find("#new_chat_message");
        $form.bind({
            "ajax:loading": function(event) { $form.find("textarea").val(""); }
        });

        var onUserEnters = function(event, user) {
            PGS.userInfo(user.id, function(userId, userData) {
                var username = userData.name;
                $chatRoom.trigger("systemMessage", { text: "<" + username + "> enter room" });
            });
        };
        var onUserExits = function(event, user) {
            PGS.userInfo(user.id, function(userId, userData) {
                var username = userData.name;
                $chatRoom.trigger("systemMessage", { text: "<" + username + "> exit room" });
            });
        };
        var onNewMessage = function(event, message) {
            PGS.userInfo(message.user, function(userId, userData) {
                var date = new Date((+message.timestamp) * 1000);
                $chatRoom.trigger("message", _.extend(message, { date: date, user: userData.name }));
            });
        };
        $chatRoom.bind({
            "userEnters": onUserEnters,
            "userExits": onUserExits,
            "newMessage": onNewMessage
        });

        var chatRoomToken = $chatRoom.data("token");
        var chatRoomId = $chatRoom.attr("id").replace("chat_room_", "");
        var socket = new io.Socket(null, { port: 8080 });

        var s = S(socket, "chat");
        s.on("authentication", function(type, message) {
            if (message.status === "OK") {
                console.log("Authenticated");
            } else {
                console.error(message);
            }
        });
        s.on("presence", function(type, message) {
            if (message.action === "enter") {
                $chatRoom.trigger("userEnters", { id: message.user });
            } else if (message.action === "exit") {
                $chatRoom.trigger("userExits", { id: message.user });
            }
        });
        s.on("message", function(type, message) {
            $chatRoom.trigger("newMessage", message);
        });
        s.onConnect(function() {
            this.send("authenticate", { userId: document.pgs.currentUser, token: chatRoomToken, chatRoom: chatRoomId });
        });
        socket.connect();
    });
});
