// This is extracted part from supervision_room.js, created when the later was responsible
// for handling all supervision process in one page. I think that topics should belong
// to group instead of supervision, so topic selection would be rewriten anyway,
// and I haven't refatored this part to better suit actual state of process, as it should
// change soon.
(function($){
    $.fn.supervisionTopicsRoom = function() {
        return this.each(function() {
            var $this            = $(this),
                $header          = $this.find("header"),
                $footer          = $this.find("footer"),
                $statusbar       = $header.find(".supervision_statusbar"),
                $topics          = $this.find(".topics_part"),
                $topicsList      = $topics.find(".list"),
                $topicsVotes     = $this.find(".topics_votes_part"),
                $membershipsList = $this.find(".members-part .members-list"),
                supervisionState = $this.data("supervision-state"),
                supervisionId    = $this.attr("id").replace("supervision_", "");

            var asyncSubmit = function() {
                return function(event) {
                    $(this).callRemote();
                    event.preventDefault();
                };
            };
            var disableSubmit = function(element) {
                return function(event) {
                    $(element || this).find("input[type=submit]").attr("disabled", "disabled");
                };
            };
            var enableSubmit = function(element) {
                return function(event) {
                    $(element || this).find("input[type=submit]").removeAttr("disabled");
                };
            };
            var removeElement = function(element) {
                return function(event) {
                    $(element || this).hide("fast", function(){ $(this).remove(); });
                };
            };
            var clearText = function(selector) {
                return function(event) {
                    $(this).find(selector).val("");
                };
            };

            var dynamicStateChangeSuccess = function(elementToRemove) {
                var caller = arguments.callee.caller;
                return function(data, status, xhr) {
                    $(elementToRemove).remove();
                    $this.find(".supervision-content").append($(data));
                    caller.call();
                };
            };

            var onGatheringTopicsState = function() {
                var $newTopicForm = $topics.find("#new_topic");

                $newTopicForm.attr("action", function(i, attr) {
                    return attr.match(/\.json$/) ? attr : attr + ".json";
                });
                $newTopicForm
                    .live({
                        "submit": asyncSubmit(),
                        "ajax:loading": disableSubmit($newTopicForm),
                        "ajax:success": removeElement($newTopicForm.closest(".form"))
                    });
            };
            var onVotingOnTopicsState = function(dynamicChange) {
                if (dynamicChange) {
                    var url = PGS.supervisionTopicsPath(supervisionId, { partial: "topics_votes" });
                    $.get(url, [], dynamicStateChangeSuccess($topics));
                } else {
                    $topicsVotes = $this.find(".topic_votes_part");

                    var $newTopicVoteForm = $topicsVotes.find("form.new_vote");
                    $newTopicVoteForm.attr("action", function(i, attr) {
                        return attr.match(/\.json$/) ? attr : attr + ".json";
                    });
                    $newTopicVoteForm
                        .live({
                            "submit": asyncSubmit(),
                            "ajax:loading": disableSubmit($newTopicVoteForm),
                            "ajax:failure": enableSubmit($newTopicVoteForm)
                        });
                }
            };

            var stateChangeCallbacks = {
                "gathering_topics": onGatheringTopicsState,
                "voting_on_topics": onVotingOnTopicsState
            };

            var onSupervisionUpdate = function(event, message) {
                if (supervisionState !== message.state) {
                    supervisionState = message.state;
                    $this.find(".waiting").hide("fast", function() { $(this).remove(); });
                    if (stateChangeCallbacks[supervisionState]) {
                        PGS.renderStatusbar(message.id);
                        stateChangeCallbacks[supervisionState](true);
                    } else {
                        document.location = PGS.supervisionPath(supervisionId);
                    }
                }
            };
            var onNewTopic = function(event, message) {
                var url = PGS.supervisionTopicPath(supervisionId, message.id, { partial: 1 });
                var onSuccess = function(data, status, xhr) {
                    var newTopic = $(data);
                    $topicsList.append(newTopic);
                    newTopic.hide().show("fast");
                };
                $.get(url, [], onSuccess);
            };

            var onAjaxComplete = function(event, xhr, status) {
                var json = $.parseJSON(xhr.response);
                if (json && json.flash) {
                    _.each(json.flash, function(message, severity) {
                        $this.trigger("flash:" + severity, message);
                    });
                }
            };

            if (stateChangeCallbacks[supervisionState]) {
                stateChangeCallbacks[supervisionState](false);
            }

            $this.bind({
                "supervisionUpdate": onSupervisionUpdate,
                "newTopic": onNewTopic,
                "ajax:complete": onAjaxComplete
            });
            $this.trigger("supervisionUpdate", { state: supervisionState });
            $statusbar.find("[title]").tooltip();
        });
    };
})(jQuery);
