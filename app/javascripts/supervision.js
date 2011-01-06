(function($){
    $.fn.supervisionRoom = function() {
        return this.each(function() {
            var $this = $(this);
            var supervisionState = $this.data("supervision-state");
            var supervisionId = $this.attr("id").replace("supervision_", "");

            var $topics = $this.find(".topics"),
                $topicsVotes = $this.find(".topics_votes"),
                $questions = $this.find(".questions");

            var onTopicState = function() {
                var $newTopicForm = $topics.find("#new_topic");

                if ($newTopicForm.length) {
                    $newTopicForm.attr("action", function(i,a){ return a+".js"; });
                    $newTopicForm.live({
                        "submit": function(event) {
                            $(this).callRemote();
                            event.preventDefault();
                        },
                        "ajax:loading": function() {
                            $newTopicForm.find("input[type=submit]").attr("disabled", "disabled");
                        },
                        "ajax:success": function() {
                            $newTopicForm.hide("fast", function(){ $(this).remove(); });
                        }
                    });
                }
            };
            var onTopicVoteState = function(dynamicChange) {
                if (dynamicChange) {
                    var url = PGS.supervisionTopicsVotesViewPath(supervisionId, { partial: 1 });
                    var onSuccess = function(data, status, xhr) {
                        var $topicsVotes = $(data);
                        $topics.remove();
                        $this.append($topicsVotes);
                        onTopicVoteState();
                    };
                    $.get(url, [], onSuccess);
                } else {
                    $topicsVotes = $this.find(".topics_votes");
                    var $newTopicVoteForm = $topicsVotes.find("form.new_vote");
                    $newTopicVoteForm.attr("action", function(i,a){ return a+".js"; });
                    $newTopicVoteForm.live({
                        "submit": function(event) {
                            $(this).callRemote();
                            event.preventDefault();
                        },
                        "ajax:loading": function() {
                            $newTopicVoteForm.find("input[type=submit]").attr("disabled", "disabled");
                        }
                    });
                }
            };
            var onTopicQuestionState = function(dynamicChange) {
                if (dynamicChange) {
                    var url = PGS.supervisionTopicQuestionsViewPath(supervisionId, { partial: 1 });
                    var onSuccess = function(data, status, xhr) {
                        var $questions = $(data);
                        $this.append($questions);
                        $topicsVotes.remove();
                        onTopicQuestionState();
                    };
                    $.get(url, [], onSuccess);
                } else {
                    $questions = $this.find(".questions");
                    var $newQuestionForm = $questions.find("form#new_question");
                    $newQuestionForm.attr("action", function(i,a){ return a+".js"; });
                    $newQuestionForm.live({
                        "submit": function(event) {
                            $(this).callRemote();
                            event.preventDefault();
                        },
                        "ajax:loading": function() {
                            $(this).find("#question_content").text("");
                        }
                    });

                    var $voteNextStepLink = $questions.find("#new_question a");
                    $voteNextStepLink.attr("href", function(i,a){ return a+".js"; });
                    $voteNextStepLink.attr("data-remote", "data-remote");
                    $voteNextStepLink.live({
                        "ajax:loading": function() {
                            $newQuestionForm.hide("fast", function() { $(this).remove(); });
                        }
                    });

                    var $newAnswerForm = $questions.find("form.answer");
                    $newAnswerForm.attr("action", function(i,a){ return a+".js"; });
                    $newAnswerForm.live({
                        "submit": function(event) {
                            $(this).callRemote();
                            event.preventDefault();
                        },
                        "ajax:loading": function() {
                            $(this).find("input[type=submit]").attr("disabled", "disabled");
                        },
                        "ajax:failure": function() {
                            $(this).find("input[type=submit]").removeAttr("disabled");
                        },
                        "ajax:success": function() {
                            var $answer = $(this).closest("div.answer");
                            $answer.hide("fast", function(){ $(this).remove(); });
                        }
                    });
                }
            };
            var onIdeaState = function(dynamicChange) {
                console.log("onIdeaState");
            };

            var stateChangeCallbacks = {
                "topic": onTopicState,
                "topic_vote": onTopicVoteState,
                "topic_question": onTopicQuestionState,
                "idea": onIdeaState
            };
            var onSupervisionUpdate = function(event, message) {
                if (supervisionState !== message.state) {
                    supervisionState = message.state;
                    $this.find(".waiting").hide("fast", function() { $(this).remove(); });
                    stateChangeCallbacks[supervisionState](true);
                }
            };
            var onNewTopic = function(event, message) {
                var url = PGS.supervisionTopicPath(supervisionId, message.id, { partial: 1 });
                var onSuccess = function(data, status, xhr) {
                    var newTopic = $(data);
                    $topics.append(newTopic);
                    newTopic.hide().show("fast");
                };
                $.get(url, [], onSuccess);
            };
            var onNewQuestion = function(event, message) {
                var url = PGS.supervisionQuestionPath(supervisionId, message.id, { partial: 1 });
                var onSuccess = function(data, status, xhr) {
                    var newQuestion = $(data);
                    $questions.append(newQuestion);
                    newQuestion.hide().show("fast");
                };
                $.get(url, [], onSuccess);
            };
            var onNewAnswer = function(event, message) {
                var url = PGS.supervisionQuestionAnswerPath(supervisionId, message.question_id, { partial: 1 });
                var onSuccess = function(data, status, xhr) {
                    var newAnswer = $(data);
                    $questions.find("#question_" + message.question_id + " .content").append(newAnswer);
                    newAnswer.hide().show("fast");
                };
                $.get(url, [], onSuccess);
            };

            $this.bind({
                "supervisionUpdate": onSupervisionUpdate,
                "newTopic": onNewTopic,
                "newQuestion": onNewQuestion,
                "newAnswer": onNewAnswer
            });

            stateChangeCallbacks[supervisionState](false);
        });
    };
})(jQuery);
