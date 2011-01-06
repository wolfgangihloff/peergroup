(function($){
    $.fn.supervisionRoom = function() {
        return this.each(function() {
            var $this = $(this);
            var supervisionState = $this.data("supervision-state");
            var supervisionId = $this.attr("id").replace("supervision_", "");

            var $topics = $this.find(".topics_part"),
                $topicsVotes = $this.find(".topics_votes_part"),
                $questions = $this.find(".questions_part"),
                $ideas = $this.find(".ideas_part");

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
                    $topicsVotes = $this.find(".topics_votes_part");
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
                    $topics = $this.find(".topics_part");
                    $questions = $this.find(".questions_part");
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

                    var $voteNextStepLink = $newQuestionForm.find("a");
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
                if (dynamicChange) {
                    var url = PGS.supervisionIdeaViewPath(supervisionId, { partial: 1 });
                    var onSuccess = function(data, status, xhr) {
                        var $ideas = $(data);
                        $this.append($ideas);
                        onIdeaState();
                    };
                    $.get(url, [], onSuccess);
                } else {
                    $ideas = $this.find(".ideas_part");
                    var $newIdeaForm = $ideas.find("form#new_idea");
                    $newIdeaForm.attr("action", function(i,a){ return a+".js"; });
                    $newIdeaForm.live({
                        "submit": function(event) {
                            $(this).callRemote();
                            event.preventDefault();
                        },
                        "ajax:loading": function(event) {
                            $(this).find("#idea_content").text("");
                        }
                    });

                    var $voteNextStepLink = $newIdeaForm.find("a");
                    $voteNextStepLink.attr("href", function(i,a){ return a+".js"; });
                    $voteNextStepLink.attr("data-remote", "data-remote");
                    $voteNextStepLink.live({
                        "ajax:loading": function() {
                            $newIdeaForm.hide("fast", function() { $(this).remove(); });
                        }
                    });

                    var $rateIdeaForm = $ideas.find("form.edit_idea");
                    $rateIdeaForm.live({
                        "submit": function(event) {
                            $(this).callRemote();
                            event.preventDefault();
                        }
                    });
                }
            };
            var onIdeaFeedbackState = function(dynamicChange) {
                if (dynamicChange) {
                    var url = PGS.supervisionIdeasFeedbackViewPath(supervisionId, { partial: 1 });
                    var onSuccess = function(data, status, xhr) {
                        var $ideasFeedback = $(data);
                        $this.append($ideasFeedback);
                        onIdeaFeedbackState();
                    };
                    $.get(url, [], onSuccess);
                } else {
                    $ideasFeedback = $this.find(".ideas_feedback_part");
                    var $newIdeasFeedback = $ideasFeedback.find("form#new_ideas_feedback");
                    $newIdeasFeedback.attr("action", function(i,a){ return a+".js"; });
                    $newIdeasFeedback.live({
                        "submit": function(event) {
                            $(this).callRemote();
                            event.preventDefault();
                        },
                        "ajax:loading": function(event) {
                            $newIdeasFeedback.hide("fast", function() { $(this).remove(); });
                        }
                    });
                }
            };
            var onSolutionState = function(dynamicChange) {
            };

            var stateChangeCallbacks = {
                "topic": onTopicState,
                "topic_vote": onTopicVoteState,
                "topic_question": onTopicQuestionState,
                "idea": onIdeaState,
                "idea_feedback": onIdeaFeedbackState,
                "solution": onSolutionState
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
                    var $newQuestion = $(data);
                    $questions.append($newQuestion);
                    newQuestion.hide().show("fast");
                };
                $.get(url, [], onSuccess);
            };
            var onNewAnswer = function(event, message) {
                var url = PGS.supervisionQuestionAnswerPath(supervisionId, message.question_id, { partial: 1 });
                var onSuccess = function(data, status, xhr) {
                    var $newAnswer = $(data);
                    $questions.find("#question_" + message.question_id + " .content").append($newAnswer);
                    newAnswer.hide().show("fast");
                };
                $.get(url, [], onSuccess);
            };
            var onNewIdea = function(event, message) {
                var url = PGS.supervisionIdeaPath(supervisionId, message.id, { partial: 1 });
                var onSuccess = function(data, status, xhr) {
                    var $newIdea = $(data);
                    var $existingIdea = $ideas.find("#idea_" + message.id);
                    if ($existingIdea.length) {
                        $existingIdea.replaceWith($newIdea);
                    } else {
                        $ideas.append($newIdea);
                        $newIdea.hide().show("fast");
                    }
                    $newIdea.find("input[type=radio].star").rating();
                };
                $.get(url, [], onSuccess);
            };
            var onNewIdeasFeedback = function(event, message) {
                var url = PGS.supervisionIdeasFeedbackPath(supervisionId, message.id, { partial: 1 });
                var onSuccess = function(data, status, xhr) {
                    var $newIdeasFeedback = $(data);
                    $ideasFeedback.append($newIdeasFeedback);
                    $newIdeasFeedback.hide().show("fast");
                };
                $.get(url, [], onSuccess);
            };
            stateChangeCallbacks[supervisionState](false);

            $this.bind({
                "supervisionUpdate": onSupervisionUpdate,
                "newTopic": onNewTopic,
                "newQuestion": onNewQuestion,
                "newAnswer": onNewAnswer,
                "newIdea": onNewIdea,
                "newIdeasFeedback": onNewIdeasFeedback
            });
        });
    };
})(jQuery);
