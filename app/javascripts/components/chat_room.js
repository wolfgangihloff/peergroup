(function($){
    var messageTemplate = _.template(
      "<li class=\"chat_message\" id=\"<?= id ?>\">" +
        "<span class=\"message-user\"><?= user ?></span> " +
        "<time datetime=\"<?= date.toISOString() ?>\"><?= date ?></time> : " +
        "<span class=\"message-content\"><?= content ?></span>" +
      "</li>"
    );
    var presenceMessageTemplate = _.template(
      "<li class=\"system_chat_message\">" +
        "<time datetime=\"<?= date.toISOString() ?>\"><?= date ?></time> : " +
        "<san class=\"message-content\"><?= content ?></span>" +
      "</li>"
    );
    // This messages should be translatable
    var presenceMessageContentTemplates = {
        "enter": _.template("<?= user ?> joined chat"),
        "exit": _.template("<?= user ?> left chat")
    };
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
                    user = message.user && message.user.name,
                    date = message.date || new Date(),
                    content = message.content || "";

                var newMessage = $(messageTemplate({id: id, user: user, date: date, content: content}));
                newMessage.find("time").timeago();
                addMessage(newMessage);
            };
            var onPresence = function(event, message) {
                var text = presenceMessageContentTemplates[message.status]({ user: message.user.name }),
                    date = new Date(), // use message.created_at maybe
                    newMessage = $(presenceMessageTemplate({date: date, content: text}));

                newMessage.find("time").timeago();
                addMessage(newMessage);
            };

            scrollMessages();
            $this.bind({
                "chat:message": onMessage,
                "chat:presence": onPresence
            });

        });
    };
})(jQuery);

