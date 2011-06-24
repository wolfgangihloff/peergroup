(function($){
    var messageTemplate = _.template(
      "<li class=\"chat_message\" id=\"<?= id ?>\">" +
        "<time datetime=\"<?= date.toISOString() ?>\"><?= displayDate ?></time> : " +
        "<span class=\"message-user\"><?= user ?></span> " +
        "<span class=\"message-content\"><?= content ?></span>" +
      "</li>"
    );
    var presenceMessageTemplate = _.template(
      "<li class=\"system_chat_message\">" +
        "<time datetime=\"<?= date.toISOString() ?>\"><?= displayDate ?></time> : " +
        "<san class=\"message-content\"><?= content ?></span>" +
      "</li>"
    );
    // This messages should be translatable
    var presenceMessageContentTemplates = {
        "enter": _.template("<?= user ?> joined chat"),
        "exit": _.template("<?= user ?> left chat")
    };

    var chatMemberTemplate = _.template(
        "<li class=\"supervision-member user\" id=\"user_<?= id ?>\">" +
          "<img class=\"gravatar\" width=\"50\" height=\"50\" src=\"<?= avatar_url ?>\" />" +
          "<span class=\"name\"><?= name ?></span>" +
        "</li>"
    );

    $.fn.chatRoom = function() {
        return this.each(function() {
            var $this = $(this),
                $messages = $this.find(".messages"),
                $messagesParent = $messages.parent();

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
                    displayDate = formattedDate(),
                    content = message.content || "";

                var newMessage = $(messageTemplate({id: id, user: user, date: date, displayDate: displayDate, content: content}));
                addMessage(newMessage);
            };

            var formattedDate = function() {
                var now = new Date(),
                    hour = now.getHours(),
                    min = now.getMinutes();
                    if (hour < 10) {
                        hour = '0' + hour;
                    }
                    if (min < 10) {
                        min = '0' + min;
                    }
                return hour+":"+min;
            };

            var addPresenceMessage = function(status, userData) {
                var text = presenceMessageContentTemplates[status]({ user: userData.name }),
                    date = new Date(),
                    displayDate = formattedDate(),
                    newMessage = $(presenceMessageTemplate({date: date, displayDate: displayDate, content: text}));
                addMessage(newMessage);
            };

            var onPresence = function(event, message) {
                var membersList = $(".members-part .members-list");
                var existingIds = _.map(membersList.find("li"), function(li) { return li.id });
                _.each(message.user_ids, function(userId) {
                    if (_.include(existingIds, "user_"+userId)) {
                        existingIds.splice(existingIds.indexOf("user_"+userId), 1);
                    } else {
                       PGS.withUserInfo(userId, function(id, userData) {
                           var newMember = $(chatMemberTemplate(userData));
                           membersList.append(newMember);
                           if (userId === message.user_id) {
                               addPresenceMessage(message.status, userData);
                           }
                       });
                    }
                });
                _.each(existingIds, function(htmlUserId) {
                    membersList.find("li#"+htmlUserId).remove();
                    PGS.withUserInfo(htmlUserId.replace(/[^\d]/g, ""), function(id, userData) {
                        addPresenceMessage(message.status, userData);
                    });
                });
            };

            scrollMessages();
            $this.bind({
                "chat:message": onMessage,
                "chat:presence": onPresence,
            });

        });
    };
})(jQuery);

