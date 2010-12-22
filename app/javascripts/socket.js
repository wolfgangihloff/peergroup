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
    $(".chat_room").each(function(i, element) {
        var $chatRoom = $(this);
        $chatRoom.chatRoom();

        var $form = $chatRoom.find("#new_chat_message");
        $form.bind({
            "ajax:loading": function(event) { $form.find("textarea").val(""); }
        });

        var onUserEnters = function(event, user) {
            var username = user.id;
            $chatRoom.trigger("systemMessage", { text: "User " + username + " enters room" });
        };
        var onUserExits = function(event, user) {
            var username = user.id;
            $chatRoom.trigger("systemMessage", { text: "User " + username + " exits room" });
        };
        var onNewMessage = function(event, message) {
            var date = new Date((+message.timestamp) * 1000);
            $chatRoom.trigger("message", _.extend(message, { date: date }));
        };
        $chatRoom.bind({
            "userEnters": onUserEnters,
            "userExits": onUserExits,
            "newMessage": onNewMessage
        });


        var chatRoomToken = $chatRoom.data("token");
        var chatRoomId = $chatRoom.attr("id").replace("chat_room_", "");
        var socket = new io.Socket(null, { port: 8080 });

        var S = function(socket) {
            var callbacks = {},
                connectCallbacks = [];

            var that = {
                socket: socket,
                on: function(type, callback) {
                    if (!callbacks[type]) { callbacks[type] = []; }
                    callbacks[type].push(callback);
                    return this;
                },
                onConnect: function(callback) {
                    connectCallbacks.push(callback);
                    return this;
                }
            };

            var onMessage = function(message) {
                if (message.type) {
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
        var s = S(socket);
        s.on("chatAuthentication", function(type, message) {
            if (message.status === "OK") {
                console.log("Authenticated");
            } else {
                console.error(message);
            }
        });
        s.on("chatPresence", function(type, message) {
            if (message.action === "enter") {
                $chatRoom.trigger("userEnters", { id: message.user });
            } else if (message.action === "exit") {
                $chatRoom.trigger("userExits", { id: message.user });
            }
        });
        s.on("chatMessage", function(type, message) {
            $chatRoom.trigger("newMessage", message);
        });
        s.onConnect(function() {
            this.socket.send({ userId: document.pgs.currentUser, token: chatRoomToken, chatRoom: chatRoomId });
        });
        socket.connect();
    });
});
