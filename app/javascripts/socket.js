(function() {
    $(".chat_room").each(function(i, element) {
        var $chatRoom = $(element);
        var $messages = $chatRoom.find(".messages");
        var chatRoomToken = $chatRoom.data("token");
        var chatRoomId = $chatRoom.attr("id").replace("chat_room_", "");

        $messages.find("time").timeago();

        var $form = $chatRoom.find("#new_chat_message");
        var addMessage = function(id, user, date, content) {
            var message = $("<li>", { "class": "chat_message", id: id }).
                append($("<span>", { "class": "user", text: user })).
                append(" ").
                append($("<time>", { datetime: date.toISOString() }).append(date).timeago()).
                append(" : ").
                append($("<span>", { "class": "content", text: content }));
            $messages.append(message);
        };
        var addSystemMessage = function(text) {
            var date = new Date();
            var message = $("<li>", { "class": "system_chat_message" }).
                append($("<time>", { datetime: date.toISOString() }).append(date).timeago()).
                append(" ").
                append($("<span>", { "class": "content", text: text }));
            $messages.append(message);
        };
        var onUserEnters = function(event, user) {
            var username = user.id;
            addSystemMessage("User " + username + " enters room");
        };
        var onUserExits = function(event, user) {
            var username = user.id;
            addSystemMessage("User " + username + " exits room");
        };
        var onNewMessage = function(event, message) {
            var date = new Date((+message.timestamp) * 1000);
            var username = message.user;
            addMessage(message.id, username, date, message.content);
        };
        $form.bind({
            "ajax:loading": function(event) { $form.find("textarea").val(""); }
        });
        $chatRoom.bind({
            "userEnters": onUserEnters,
            "userExits": onUserExits,
            "newMessage": onNewMessage
        });


        var socket = new io.Socket(null, { port: 8080 });
        socket.on("connect", function() {
            socket.send({ userId: document.pgs.currentUser, token: chatRoomToken, chatRoom: chatRoomId });
        });

        var authenticated = false;
        socket.on("message", function(message) {
            if (!authenticated) {
                if (message && message.status === "OK") {
                    console.log("Authenticated");
                    authenticated = true;
                } else {
                    console.error(message);
                }
            } else {
                switch (message.type) {
                case "presence":
                    if (message.action === "enter") {
                        $chatRoom.trigger("userEnters", { id: message.user });
                    } else if (message.action === "exit") {
                        $chatRoom.trigger("userExits", { id: message.user });
                    }
                    break;

                case "message":
                    $chatRoom.trigger("newMessage", message);
                    break;
                default: break;
                }
            }
        });
        socket.connect();
    });
})();
