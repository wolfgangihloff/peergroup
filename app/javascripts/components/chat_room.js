(function($){
    $.fn.chatRoom = function() {
        return this.each(function() {
            var $this = $(this),
                $messagesPart = $this.find(".messages_part"),
                $messages = $this.find(".messages");

            $messages.find("time").timeago();

            var scrollMessages = function(fn) {
                var currentScroll = $messagesPart.scrollTop();
                var maximumScroll = $messages.height() - $messagesPart.height();
                fn();
                if (currentScroll === maximumScroll) {
                    $messagesPart.scrollTop($messages.height() - $messagesPart.height());
                }
            };

            var onMessage = function(event, message) {
                var id = message.id || -1,
                    user = message.user || "(unknown)",
                    date = message.date || new Date(),
                    content = message.content || "";

                var newMessage = $("<li>", { "class": "chat_message", id: id }).
                    append($("<span>", { "class": "message-user", text: user })).
                    append(" ").
                    append($("<time>", { datetime: date.toISOString() }).append(date).timeago()).
                    append(" : ").
                    append($("<span>", { "class": "message-content", text: content }));

                scrollMessages(function(){
                    $messages.append(newMessage);
                });
            };
            var onSystemMessage = function(event, message) {
                var text = message.text || "",
                    date = message.date || new Date();

                var newMessage = $("<li>", { "class": "system_chat_message" }).
                    append($("<time>", { datetime: date.toISOString() }).append(date).timeago()).
                    append(" ").
                    append($("<span>", { "class": "message-content", text: text }));

                scrollMessages(function(){
                    $messages.append(newMessage);
                });
            };

            $this.bind({
                "message": onMessage,
                "systemMessage": onSystemMessage
            });


        });
    };
})(jQuery);

