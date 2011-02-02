(function($){
    $.fn.chatRoom = function() {
        return this.each(function() {
            var $this = $(this),
                $messages = $this.find(".messages"),
                $messagesParent = $messages.parent();

            $messages.find("time").timeago();


            var scrollMessages = function() {
                var newScrollTop = $messages.height() - $messagesParent.height();
                $messagesParent.scrollTop(newScrollTop);
            };
            var addMessage = function(message) {
                var shouldScroll =
                    ($messagesParent.scrollTop() === $messages.height() - $messagesParent.height()) || // if messages are already scrolled
                    ($messagesParent.height() > $messages.height()); // or if there are less messages than possible to display

                $messages.append(message);

                if (shouldScroll) {
                    scrollMessages();
                }
            };

            var onMessage = function(event, message) {
                var id = message.id || -1,
                    user = message.user || "(unknown)",
                    date = message.date || new Date(),
                    content = message.content || "";

                var newMessage = $("<li>", { "class": "chat_message", id: id })
                    .append($("<span>", { "class": "message-user", text: user }))
                    .append(" ")
                    .append($("<time>", { datetime: date.toISOString() }).append(date).timeago())
                    .append(" : ")
                    .append($("<span>", { "class": "message-content", text: content }));

                addMessage(newMessage);
            };
            var onSystemMessage = function(event, message) {
                var text = message.text || "",
                    date = message.date || new Date();

                var newMessage = $("<li>", { "class": "system_chat_message" })
                    .append($("<time>", { datetime: date.toISOString() }).append(date).timeago())
                    .append(" ")
                    .append($("<span>", { "class": "message-content", text: text }));

                addMessage(newMessage);
            };

            scrollMessages();
            $this.bind({
                "message": onMessage,
                "systemMessage": onSystemMessage
            });


        });
    };
})(jQuery);

