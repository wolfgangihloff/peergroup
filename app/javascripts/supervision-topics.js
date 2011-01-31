(function($){
    $.fn.supervisionTopicsRoom = function() {
        return this.each(function() {
            var $this                 = $(this),
                $header               = $this.find("header"),
                $footer               = $this.find("footer"),
                $statusbar            = $header.find(".supervision_statusbar"),
                $topics               = $this.find(".topics_part"),
                $topicsList           = $topics.find(".list"),
                $topicsVotes          = $this.find(".topics_votes_part"),
                supervisionState      = $this.data("supervision-state"),
                supervisionId         = $this.attr("id").replace("supervision_", "");

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
                    $statusbar.find(".current_state").removeClass("current_state");
                    $statusbar.find("[data-state-name="+supervisionState+"]").addClass("current_state");
                    if (stateChangeCallbacks[supervisionState]) {
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

            if (stateChangeCallbacks[supervisionState]) {
                stateChangeCallbacks[supervisionState](false);

                $this.bind({
                    "supervisionUpdate": onSupervisionUpdate,
                    "newTopic": onNewTopic
                });
                $this.trigger("supervisionUpdate", { state: supervisionState });
                $statusbar.find("[title]").tooltip();
            }
        });
    };
})(jQuery);
