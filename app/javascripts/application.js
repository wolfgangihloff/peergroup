//= require "lib/jquery"
// BIG WARNING:
// this is jquery-ui 1.9m3 version, it's not yet stable, so be prapared
// to update it when needed
//= require "lib/jquery-ui"
//= require "lib/jquery_ujs"
//= require "lib/underscore"

//= require "lib/jquery.form"
//= require "lib/jquery.rating"

//= require "pgs"
//= require "s"
//= require "util"

//= require "components/chat_room"
//= require "components/supervision_room"
//= require "components/flash_notifications"

jQuery(function($) {
    // Add socket.io external javascript, use:
    //     PGS.load("socket.io", function() {
    //         ... // socket.io is loaded
    //     });
    (function () {
        var nodeServerUrl = document.pgs.node.protocol + "://" + document.pgs.node.host + ":" + document.pgs.node.port,
            socketIoUrl = nodeServerUrl + "/socket.io/socket.io.js";
        // copied from app/node.js/socket.io/support/socket.io-client/socket.io.js
        window.WEB_SOCKET_SWF_LOCATION = nodeServerUrl + "/socket.io/lib/vendor/web-socket-js/WebSocketMain.swf";
        PGS.addModule("socket.io", socketIoUrl);
    })();

    $(".supervision").each(function (i, el) {
        $supervision = $(this);
        $chatRoom = $supervision.find(".chat_room");
        $supervisionContent = $supervision.find(".supervision-content");

        var $pusher = $("<div style='height:0;margin:0;padding:0'>");
        $chatRoom.before($pusher);
        var scrollCallback = function () {
            var y = $(this).scrollTop(),
                top = $pusher.offset().top - 15,
                maxTop = $supervisionContent.height() - $chatRoom.height(),
                pushAmount = Math.max(0, Math.min(y - top, maxTop));
            $pusher.animate({height: pushAmount + "px"}, 500);
        };
        $(window).scroll(_.throttle(scrollCallback, 100));
    });

    var flash = $(".flash-messages").flashnotifications({animate: true});
    $(document).bind({
        "flash:notice": function (event, message) { flash.flashnotifications("notice", message); },
        "flash:alert": function (event, message) { flash.flashnotifications("alert", message); }
    });

    $(".flash-messages").each(function (i, element) {
      console.log("flash_messages");
      PGS.withSocket("group", function (s) {
        console.log("group:");
        s.on("message", function (type, message) {
          flash.flashnotifications("notice", "hello from js");
        });
      });
    });

    $(".chat_room").each(function (i, element) {
        var $chatRoom = $(this);
        $chatRoom.chatRoom();

        var $form = $chatRoom.find("#new_chat_message");
        $form.bind({
            "ajax:success": function (event) { $form.find("#chat_message_content").val(""); }
        });

        var onUserEnters = function(event, user) {
            PGS.withUserInfo(user.id, function (userId, userData) {
                var username = userData.name;
                $chatRoom.trigger("systemMessage", { text: "<" + username + "> enter room" });
            });
        };
        var onUserExits = function (event, user) {
            PGS.withUserInfo(user.id, function (userId, userData) {
                var username = userData.name;
                $chatRoom.trigger("systemMessage", { text: "<" + username + "> exit room" });
            });
        };
        var onNewMessage = function (event, message) {
            PGS.withUserInfo(message.user, function (userId, userData) {
                var date = new Date((+message.timestamp) * 1000);
                $chatRoom.trigger("message", _.extend(message, { date: date, user: userData.name }));
            });
        };
        $chatRoom.bind({
            "userEnters": onUserEnters,
            "userExits": onUserExits,
            "newMessage": onNewMessage
        });

        var chatRoomToken = $chatRoom.data("token"),
            chatRoomId = $chatRoom.attr("id").replace("chat_room_", "");

        PGS.withSocket("chat", function (s) {
            s.on("authentication", function (type, message) {
                if (message.status === "OK") {
                    if (window.console && window.console.log) {
                        console.log("chat: Authenticated");
                    }
                    $chatRoom.addClass("connected");
                } else {
                    if (window.console && window.console.error) {
                        console.error(message);
                    }
                    $chatRoom.addClass("connection-error");
                }
            });
            s.on("chat_presence", function (type, message) {
                $chatRoom.trigger("chat:presence", message.chat_presence);
            });
            s.on("chat_message", function (type, message) {
                $chatRoom.trigger("chat:message", message.chat_message);
            });
            s.onConnect(function () {
                this.send("authenticate", { userId: document.pgs.currentUser, token: chatRoomToken, chatRoomId: chatRoomId });
            });
        });
    });

    $("#supervisions_show .supervision").each(function (i, element) {
        var $supervision = $(this);
        $supervision.supervisionRoom();

        var supervisionToken = $supervision.data("token"),
            supervisionId = $supervision.attr("id").replace("supervision_", "");

        PGS.withSocket("supervision", function (s) {
            s.on("authentication", function (type, message) {
                if (message.status === "OK") {
                    if (window.console && window.console.log) {
                        console.log("supervision: Authenticated");
                    }
                    $supervision.addClass("connected");
                } else {
                    if (window.console && window.console.error) {
                        console.error(message);
                    }
                    $supervision.addClass("connection-error");
                }
            });
            s.onConnect(function() {
                this.send("authenticate", { userId: document.pgs.currentUser, token: supervisionToken, supervisionId: supervisionId });
            });
            s.on("supervision", function(type, message) {
                $supervision.trigger("supervision:update", message.supervision);
            });
            s.on("topic", function(type, message) {
                $supervision.trigger("supervision:topic", message.topic);
            });
            s.on("vote", function(type, message) {
                $supervision.trigger("supervision:topic_vote", message.vote);
            });
            s.on("question", function(type, message) {
                $supervision.trigger("supervision:question", message.question);
            });
            s.on("answer", function(type, message) {
                $supervision.trigger("supervision:answer", message.answer);
            });
            s.on("idea", function(type, message) {
                $supervision.trigger("supervision:idea", message.idea);
            });
            s.on("ideas_feedback", function(type, message) {
                $supervision.trigger("supervision:ideasFeedback", message.ideas_feedback);
            });
            s.on("solution", function(type, message) {
                $supervision.trigger("supervision:solution", message.solution);
            });
            s.on("solutions_feedback", function(type, message) {
                $supervision.trigger("supervision:solutionsFeedback", message.solutions_feedback);
            });
            s.on("supervision_feedback", function(type, message) {
                $supervision.trigger("supervision:supervisionFeedback", message.supervision_feedback);
            });
            s.on("idle_status_changed", function(type, message) {
                $supervision.trigger("supervision:idleStatusChanged", message.idle_status_changed);
            });
        });
    });
});
