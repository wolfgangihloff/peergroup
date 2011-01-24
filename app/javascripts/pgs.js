(function() {
    var root = this;
    var usersCache = {};
    var path = function(pathComponents, options) {
        options = options || {};

        var p = "/" + pathComponents.join("/");
        if (options.format) {
            p = p + "." + options.format;
            delete options.format;
        }
        var params = [];
        for (var k in options) {
            if (options.hasOwnProperty(k)) {
                params.push([k, encodeURIComponent(options[k])].join("="));
            }
        }
        if (params.length) {
            p = p + "?" + params.join("&");
        }
        return p;
    };
    var socket;

    var PGS = {
        userInfo: function(userId, callback) {
            if (usersCache[userId]) {
                callback.call({}, userId, usersCache[userId]);
            } else {
                var onSuccess = function(data, textStatus, xhr) {
                    usersCache[userId] = data.user;
                    callback.call({}, userId, usersCache[userId]);
                };
                $.get(PGS.userPath(userId, { format: "json" }), [], onSuccess, "json");
            }
        },
                    
        userPath: function(userId, options) {
            return path(["users", userId], options);
        },

        supervisionPath: function(supervisionId, options) {
            return path(["supervisions", supervisionId], options);
        },

        supervisionTopicsPath: function(supervisionId, options) {
            return path(["supervisions", supervisionId, "topics"], options);
        },

        supervisionTopicPath: function(supervisionId, topicId, options) {
            return path(["supervisions", supervisionId, "topics", topicId], options);
        },

        supervisionQuestionPath: function(supervisionId, questionId, options) {
            return path(["supervisions", supervisionId, "questions", questionId], options);
        },

        supervisionIdeaPath: function(supervisionId, ideaId, options) {
            return path(["supervisions", supervisionId, "ideas", ideaId], options);
        },

        supervisionIdeasFeedbackPath: function(supervisionId, options) {
            return path(["supervisions", supervisionId, "ideas_feedback"], options);
        },

        supervisionSolutionPath: function(supervisionId, solutionId, options) {
            return path(["supervisions", supervisionId, "solutions", solutionId], options);
        },

        supervisionSolutionsFeedbackPath: function(supervisionId, options) {
            return path(["supervisions", supervisionId, "solutions_feedback"], options);
        },

        supervisionSupervisionFeedbackPath: function(supervisionId, supervisionFeedbackId, options) {
            return path(["supervisions", supervisionId, "supervision_feedbacks", supervisionFeedbackId], options);
        },

        getSocket: function() {
            if (typeof socket === "undefined") {
                WEB_SOCKET_SWF_LOCATION = document.location.protocol + "//" + document.location.hostname + ":8080" + WEB_SOCKET_SWF_LOCATION;
                socket = new io.Socket(null, { port: 8080 });
                socket.connect();
            }
            return socket;
        }

    };
 
    root.PGS = PGS;
})();
