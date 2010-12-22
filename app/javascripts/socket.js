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

                var message = $("<li>", { "class": "chat_message", id: id }).
                    append($("<span>", { "class": "user", text: user })).
                    append(" ").
                    append($("<time>", { datetime: date.toISOString() }).append(date).timeago()).
                    append(" : ").
                    append($("<span>", { "class": "content", text: content }));
                $messages.append(message);
            };
            var onSystemMessage = function(event, message) {
                var text = message.text || "",
                    date = message.date || new Date();

                var message = $("<li>", { "class": "system_chat_message" }).
                    append($("<time>", { datetime: date.toISOString() }).append(date).timeago()).
                    append(" ").
                    append($("<span>", { "class": "content", text: text }));
                $messages.append(message);
            };

            $this.bind({
                "message": onMessage,
                "systemMessage": onSystemMessage
            });


        });
    };
})(jQuery);
(function() {
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
