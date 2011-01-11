(function($){
    $.fn.supervisionRoom = function() {
        return this.each(function() {
            var $this                 = $(this),
                $header               = $this.find("header"),
                $footer               = $this.find("footer"),
                $statusbar            = $header.find(".supervision_statusbar"),
                $topics               = $this.find(".topics_part"),
                $topicsVotes          = $this.find(".topics_votes_part"),
                $questions            = $this.find(".questions_part"),
                $ideas                = $this.find(".ideas_part"),
                $ideasFeedback        = $this.find(".ideas_feedback_part"),
                $solutions            = $this.find(".solutions_part"),
                $solutionsFeedback    = $this.find(".solutions_feedback_part"),
                $supervisionFeedbacks = $this.find(".supervision_feedbacks_part"),
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
            var eachAppend = function(sufix) {
                return function(index, text) {
                    return text + sufix;
                };
            };
            var eachAppendJs = eachAppend(".js");

            var dynamicStateChangeSuccess = function(elementToRemove) {
                var caller = arguments.callee.caller;
                return function(data, status, xhr) {
                    $(elementToRemove).remove();
                    $this.find("footer").before($(data));
                    caller.call();
                };
            };

            var onTopicState = function() {
                var $newTopicForm = $topics.find("#new_topic");

                $newTopicForm
                    .attr("action", eachAppendJs)
                    .live({
                        "submit": asyncSubmit(),
                        "ajax:loading": disableSubmit($newTopicForm),
                        "ajax:success": removeElement($newTopicForm)
                    });
            };
            var onTopicVoteState = function(dynamicChange) {
                if (dynamicChange) {
                    var url = PGS.supervisionPath(supervisionId, { partial: "topics_votes" });
                    $.get(url, [], dynamicStateChangeSuccess($topics));
                } else {
                    $topicsVotes = $this.find(".topics_votes_part");

                    var $newTopicVoteForm = $topicsVotes.find("form.new_vote");
                    $newTopicVoteForm
                        .attr("action", eachAppendJs)
                        .live({
                            "submit": asyncSubmit(),
                            "ajax:loading": disableSubmit($newTopicVoteForm),
                            "ajax:failure": enableSubmit($newTopicVoteForm)
                        });
                }
            };
            var onTopicQuestionState = function(dynamicChange) {
                if (dynamicChange) {
                    var url = PGS.supervisionPath(supervisionId, { partial: "questions" });
                    $.get(url, [], dynamicStateChangeSuccess($topicsVotes));
                } else {
                    $topics = $this.find(".topics_part");
                    $questions = $this.find(".questions_part");

                    var $newQuestionForm = $questions.find("form#new_question");
                    $newQuestionForm
                        .attr("action", eachAppendJs)
                        .live({
                            "submit": asyncSubmit(),
                            "ajax:loading": clearText("#question_content")
                        });

                    var $voteNextStepLink = $newQuestionForm.find("a");
                    $voteNextStepLink
                        .attr({
                            "href": eachAppendJs,
                            "data-remote": "data-remote"
                        })
                        .live({
                            "ajax:loading": removeElement($newQuestionForm)
                        });

                    var $newAnswerForm = $questions.find("form.answer");
                    $newAnswerForm
                        .attr("action", eachAppendJs)
                        .live({
                            "submit": asyncSubmit(),
                            "ajax:loading": disableSubmit(),
                            "ajax:failure": enableSubmit(),
                            "ajax:success": function() {
                                var $answer = $(this).closest("div.answer");
                                removeElement($answer)();
                            }
                        });
                }
            };
            var onIdeaState = function(dynamicChange) {
                if (dynamicChange) {
                    var url = PGS.supervisionPath(supervisionId, { partial: "ideas" });
                    $.get(url, [], dynamicStateChangeSuccess());
                } else {
                    $ideas = $this.find(".ideas_part");

                    var $newIdeaForm = $ideas.find("form#new_idea");
                    $newIdeaForm
                        .attr("action", eachAppendJs)
                        .live({
                            "submit": asyncSubmit(),
                            "ajax:loading": clearText("#idea_content")
                        });

                    var $voteNextStepLink = $newIdeaForm.find("a");
                    $voteNextStepLink
                        .attr({
                            "href": eachAppendJs,
                            "data-remote": "data-remote"
                        })
                        .live({
                            "ajax:loading": removeElement($newIdeaForm)
                        });

                    var $rateIdeaForm = $ideas.find("form.edit_idea");
                    $rateIdeaForm
                        .attr("action", eachAppendJs)
                        .live({
                            "submit": asyncSubmit(),
                            "ajax:loading": removeElement()
                        });
                }
            };
            var onIdeaFeedbackState = function(dynamicChange) {
                if (dynamicChange) {
                    var url = PGS.supervisionPath(supervisionId, { partial: "ideas_feedback" });
                    $.get(url, [], dynamicStateChangeSuccess());
                } else {
                    $ideasFeedback = $this.find(".ideas_feedback_part");

                    var $newIdeasFeedbackForm = $ideasFeedback.find("form#new_ideas_feedback");
                    $newIdeasFeedbackForm
                        .attr("action", eachAppendJs)
                        .live({
                            "submit": asyncSubmit(),
                            "ajax:loading": removeElement($newIdeasFeedbackForm)
                        });
                }
            };
            var onSolutionState = function(dynamicChange) {
                if (dynamicChange) {
                    var url = PGS.supervisionPath(supervisionId, { partial: "solutions" });
                    $.get(url, [], dynamicStateChangeSuccess());
                } else {
                    $solutions = $this.find(".solutions_part");

                    var $newSolutionForm = $solutions.find("form#new_solution");
                    $newSolutionForm
                        .attr("action", eachAppendJs)
                        .live({
                            "submit": asyncSubmit(),
                            "ajax:loading": clearText("#solution_content")
                        });

                    var $voteNextStepLink = $newSolutionForm.find("a");
                    $voteNextStepLink
                        .attr({
                            "href": eachAppendJs,
                            "data-remote": "data-remote"
                        })
                        .live({
                            "ajax:loading": removeElement($newSolutionForm)
                        });

                    var $rateSolutionForm = $solutions.find("form.edit_solution");
                    $rateSolutionForm
                        .attr("action", eachAppendJs)
                        .live({
                            "submit": asyncSubmit(),
                            "ajax:loading": removeElement()
                        });
                }
            };
            var onSolutionFeedbackState = function(dynamicChange) {
                if (dynamicChange) {
                    var url = PGS.supervisionPath(supervisionId, { partial: "solutions_feedback" });
                    $.get(url, [], dynamicStateChangeSuccess());
                } else {
                    $solutionsFeedback = $this.find(".solutions_feedback_part");

                    var $newSolutionsFeedbackForm = $solutionsFeedback.find("form#new_solutions_feedback");
                    $newSolutionsFeedbackForm
                        .attr("action", eachAppendJs)
                        .live({
                            "submit": asyncSubmit(),
                            "ajax:loading": removeElement()
                        });
                }
            };
            var onSupervisionFeedbackState = function(dynamicChange) {
                if (dynamicChange) {
                    var url = PGS.supervisionPath(supervisionId, { partial: "supervision_feedbacks" });
                    $.get(url, [], dynamicStateChangeSuccess());
                } else {
                    $supervisionFeedbacks = $this.find(".supervision_feedbacks_part");

                    var $newSupervisionFeedbackForm = $supervisionFeedbacks.find("form#new_supervision_feedback");
                    $newSupervisionFeedbackForm
                        .attr("action", eachAppendJs)
                        .live({
                            "submit": asyncSubmit(),
                            "ajax:loading": removeElement()
                        });
                }
            };
            var onFinishedState = function(dynamicChange) {
                if (dynamicChange) {
                    var url = PGS.supervisionPath(supervisionId, { partial: "finished" });
                    var onSuccess = function(data, status, xhr) {
                        var $notice = $(data);
                        $this.find("header,footer").append($notice);
                        $notice.hide().show("fast");
                        onFinishedState();
                    };
                    $.get(url, [], onSuccess);
                }
            };

            var stateChangeCallbacks = {
                "topic": onTopicState,
                "topic_vote": onTopicVoteState,
                "topic_question": onTopicQuestionState,
                "idea": onIdeaState,
                "idea_feedback": onIdeaFeedbackState,
                "solution": onSolutionState,
                "solution_feedback": onSolutionFeedbackState,
                "supervision_feedback": onSupervisionFeedbackState,
                "finished": onFinishedState
            };
            var onSupervisionUpdate = function(event, message) {
                if (supervisionState !== message.state) {
                    supervisionState = message.state;
                    $this.find(".waiting").hide("fast", function() { $(this).remove(); });
                    $statusbar.find(".current_state").removeClass("current_state");
                    $statusbar.find("[data-state-name="+supervisionState+"]").addClass("current_state");
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
                    $newQuestion.hide().show("fast");
                };
                $.get(url, [], onSuccess);
            };
            var onNewAnswer = function(event, message) {
                var url = PGS.supervisionQuestionPath(supervisionId, message.question_id, { partial: 1 });
                var onSuccess = function(data, status, xhr) {
                    var $newQuestion = $(data);
                    $questions.find("#question_" + message.question_id).replaceWith($newQuestion);
                    $newQuestion.hide().show("fast");
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
            var onNewSolution = function(event, message) {
                var url = PGS.supervisionSolutionPath(supervisionId, message.id, { partial: 1 });
                var onSuccess = function(data, status, xhr) {
                    var $newSolution = $(data);
                    var $existingSolution = $solutions.find("#solution_" + message.id);
                    if ($existingSolution.length) {
                        $existingSolution.replaceWith($newSolution);
                    } else {
                        $solutions.append($newSolution);
                        $newSolution.hide().show("fast");
                    }
                    $newSolution.find("input[type=radio].star").rating();
                };
                $.get(url, [], onSuccess);
            };
            var onNewSolutionsFeedback = function(event, message) {
                var url = PGS.supervisionSolutionsFeedbackPath(supervisionId, message.id, { partial: 1 });
                var onSuccess = function(data, status, xhr) {
                    var $newSolutionsFeedback = $(data);
                    $solutionsFeedback.append($newSolutionsFeedback);
                    $newSolutionsFeedback.hide().show("fast");
                };
                $.get(url, [], onSuccess);
            };
            var onNewSupervisionFeedback = function(event, message) {
                var url = PGS.supervisionSupervisionFeedbackPath(supervisionId, message.id, { partial: 1 });
                var onSuccess = function(data, status, xhr) {
                    var $newSupervisionFeedback = $(data);
                    $supervisionFeedbacks.append($newSupervisionFeedback);
                    $newSupervisionFeedback.hide().show("fast");
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
                "newIdeasFeedback": onNewIdeasFeedback,
                "newSolution": onNewSolution,
                "newSolutionsFeedback": onNewSolutionsFeedback,
                "newSupervisionFeedback": onNewSupervisionFeedback
            });
            $statusbar.tooltip({
                open: function() {
                    var tooltip = $(this).tooltip("widget");
                    $(document).mousemove(function(event) {
                        tooltip.position({
                            my: "left center",
                            at: "right center",
                            offset: "25 25",
                            of: event
                        });
                    })
                    // trigger once to override element-relative positioning
                    .mousemove();
                },
                close: function() {
                    $(document).unbind("mousemove");
                }
            });
        });
    };
})(jQuery);
