//= require "lib/jquery"
// BIG WARNING:
// this is jquery-ui 1.9m3 version, it's not yet stable, so be prapared
// to update it when needed
//= require "lib/jquery-ui"
//= require "lib/rails"
//= require "lib/underscore"

//= require "lib/jquery.timeago"
jQuery.timeago.settings.allowFuture = true;
//= require "lib/jquery.form"
//= require "lib/jquery.rating"
//
//= require "pgs"
//= require "s"

//= require "components/chat_room"
//= require "components/supervision_room"
//= require "components/supervision_topics_room"
//= require "components/flash_notifications"

jQuery(function($) {
    // Add socket.io external javascript, use:
    //     PGS.load("socket.io", function() {
    //         ... // socket.io is loaded
    //     });
    (function(){
        var nodeServerUrl = document.location.protocol + "//" + document.location.hostname + ":8080";
        var socketIoUrl = nodeServerUrl + "/socket.io/socket.io.js";
        // copied from app/node.js/socket.io/support/socket.io-client/socket.io.js
        window.WEB_SOCKET_SWF_LOCATION = nodeServerUrl + "/socket.io/lib/vendor/web-socket-js/WebSocketMain.swf";
        PGS.addModule("socket.io", socketIoUrl);
    })();

    $(".supervision").each(function(i,el) {
        $supervision = $(this);
        $chatRoom = $supervision.find(".chat_room");
        $supervisionContent = $supervision.find(".supervision-content");

        var $pusher = $("<div style='height:0;margin:0;padding:0'>");
        $chatRoom.before($pusher);
        var scrollCallback = function() {
            var y = $(this).scrollTop();
            var top = $pusher.offset().top - 15;
            var maxTop = $supervisionContent.height() - $chatRoom.height();
            var pushAmount = Math.max(0, Math.min(y-top, maxTop))
            $pusher.animate({height: pushAmount + "px"}, 500);
        };
        $(window).scroll(_.throttle(scrollCallback, 100));
    });

    var flash = $(".flash-messages").flashnotifications({animate: true});
    $(document).bind({
        "flash:notice": function(event, message) { flash.flashnotifications("notice", message); },
        "flash:alert": function(event, message) { flash.flashnotifications("alert", message); }
    });

    $(".chat_room").each(function(i, element) {
        var $chatRoom = $(this);
        $chatRoom.chatRoom();

        var $form = $chatRoom.find("#new_chat_message");
        $form.bind({
            "ajax:loading": function(event) { $form.find("#chat_message_content").val(""); }
        });

        var onUserEnters = function(event, user) {
            PGS.withUserInfo(user.id, function(userId, userData) {
                var username = userData.name;
                $chatRoom.trigger("systemMessage", { text: "<" + username + "> enter room" });
            });
        };
        var onUserExits = function(event, user) {
            PGS.withUserInfo(user.id, function(userId, userData) {
                var username = userData.name;
                $chatRoom.trigger("systemMessage", { text: "<" + username + "> exit room" });
            });
        };
        var onNewMessage = function(event, message) {
            PGS.withUserInfo(message.user, function(userId, userData) {
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

        PGS.withSocket("chat", function(s) {
            s.on("authentication", function(type, message) {
                if (message.status === "OK") {
                    if (window.console && window.console.log) {
                        console.log("chat: Authenticated");
                    }
                } else {
                    if (window.console && window.console.error) {
                        console.error(message);
                    }
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
        });
    });

    $("#topics_index .supervision").each(function(i, element) {
        var $supervision = $(this);
        $supervision.supervisionTopicsRoom();

        var supervisionToken = $supervision.data("token");
        var supervisionId = $supervision.attr("id").replace("supervision_", "");

        PGS.withSocket("supervision", function(s) {
            s.on("authentication", function(type, message) {
                if (message.status === "OK") {
                    if (window.console && window.console.log) {
                        console.log("supervision: Authenticated");
                    }
                } else {
                    if (window.console && window.console.error) {
                        console.error(message);
                    }
                }
            });
            s.onConnect(function() {
                this.send("authenticate", { userId: document.pgs.currentUser, token: supervisionToken, supervision: supervisionId });
            });
            s.on("supervision", function(type, message) {
                $supervision.trigger("supervisionUpdate", message.supervision);
            });
            s.on("topic", function(type, message) {
                $supervision.trigger("newTopic", message.topic);
            });
            s.on("supervision_membership", function(type, message) {
                $supervision.trigger("supervisionMembership", message.supervision_membership);
            });
        });
    });

    $("#supervisions_show .supervision").each(function(i, element) {
        var $supervision = $(this);
        $supervision.supervisionRoom();

        var supervisionToken = $supervision.data("token");
        var supervisionId = $supervision.attr("id").replace("supervision_", "");

        PGS.withSocket("supervision", function(s) {
            s.on("authentication", function(type, message) {
                if (message.status === "OK") {
                    if (window.console && window.console.log) {
                        console.log("supervision: Authenticated");
                    }
                } else {
                    if (window.console && window.console.error) {
                        console.error(message);
                    }
                }
            });
            s.onConnect(function() {
                this.send("authenticate", { userId: document.pgs.currentUser, token: supervisionToken, supervision: supervisionId });
            });
            s.on("supervision", function(type, message) {
                $supervision.trigger("supervisionUpdate", message.supervision);
            });
            s.on("question", function(type, message) {
                $supervision.trigger("newQuestion", message.question);
            });
            s.on("answer", function(type, message) {
                $supervision.trigger("newAnswer", message.answer);
            });
            s.on("idea", function(type, message) {
                $supervision.trigger("newIdea", message.idea);
            });
            s.on("ideas_feedback", function(type, message) {
                $supervision.trigger("newIdeasFeedback", message.ideas_feedback);
            });
            s.on("solution", function(type, message) {
                $supervision.trigger("newSolution", message.solution);
            });
            s.on("solutions_feedback", function(type, message) {
                $supervision.trigger("newSolutionsFeedback", message.solutions_feedback);
            });
            s.on("supervision_feedback", function(type, message) {
                $supervision.trigger("newSupervisionFeedback", message.supervision_feedback);
            });
            s.on("supervision_membership", function(type, message) {
                $supervision.trigger("supervisionMembership", message.supervision_membership);
            });
        });
    });

});
