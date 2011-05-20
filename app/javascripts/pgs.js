(function() {
    var root = this;
    var usersCache = {};
    var socket;
    var modules = {};

    var PGS = {

        addModule: function(moduleName, url) {
            if (!modules[moduleName]) {
                modules[moduleName] = { loaded: false, url: url };
            }
        },

        load: function(moduleName, callback) {
            if (modules[moduleName].loaded) {
                callback.call({});
            } else {
                $.ajax({
                    url: modules[moduleName].url,
                    dataType: "script",
                    cache: true,
                    success: function(){ callback.call({}); },
                });
            }
        },

        withSocket: function(namespace, callback) {
            this.load("socket.io", function() {
                if (typeof socket === "undefined") {
                    socket = new io.Socket(null, { port: 8080 });
                    socket.connect();
                }
                callback.call({}, S(socket, namespace));
            });
        },

        withUserInfo: function(userId, callback) {
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

        renderStatusbar: function(supervisionId) {
            if (supervisionId) {
                $.get(PGS.supervisionStatusbarPath(supervisionId, {format: "js"}));
            }
        },

        path: function(pathComponents, options) {
            options = options || {};

            var p = "/" + pathComponents.join("/");
            if (options.format) {
                p = p + "." + options.format;
                delete options.format;
            }
            var params = [];
            for (var k in options) {
                if (Object.hasOwnProperty.call(options, k)) {
                    params.push([k, encodeURIComponent(options[k])].join("="));
                }
            }
            if (params.length) {
                p = p + "?" + params.join("&");
            }
            return p;
        },

        userPath: function(userId, options) {
            return this.path(["users", userId], options);
        },

        supervisionPath: function(supervisionId, options) {
            return this.path(["supervisions", supervisionId], options);
        },

        supervisionTopicsPath: function(supervisionId, options) {
            return this.path(["supervisions", supervisionId, "topics"], options);
        },

        supervisionTopicPath: function(supervisionId, topicId, options) {
            return this.path(["topics", topicId], options);
        },

        supervisionQuestionPath: function(supervisionId, questionId, options) {
            return this.path(["questions", questionId], options);
        },

        supervisionIdeaPath: function(supervisionId, ideaId, options) {
            return this.path(["ideas", ideaId], options);
        },

        supervisionIdeasFeedbackPath: function(supervisionId, options) {
            return this.path(["supervisions", supervisionId, "ideas_feedback"], options);
        },

        supervisionSolutionPath: function(supervisionId, solutionId, options) {
            return this.path(["solutions", solutionId], options);
        },

        supervisionSolutionsFeedbackPath: function(supervisionId, options) {
            return this.path(["supervisions", supervisionId, "solutions_feedback"], options);
        },

        supervisionSupervisionFeedbackPath: function(supervisionId, supervisionFeedbackId, options) {
            return this.path(["supervision_feedbacks", supervisionFeedbackId], options);
        },
        supervisionStatusbarPath: function(supervisionId, options) {
            return this.path(["supervisions", supervisionId, "statusbar"], options);
        }

    };

    root.PGS = PGS;
})();
