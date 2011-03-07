(function($){
    var capitalize = function(str) {
        var result = "";
        var strParts = str.split("_");
        for (var i = 0; i < strParts.length; i++) {
            if (strParts[i].length > 1) {
                result += strParts[i].charAt(0).toUpperCase() + strParts[i].substring(1);
            } else {
                result += strParts[i].toUpperCase();
            }
        }
        return result;
    };

    var asyncSubmitCallback = function(event) {
        var $this = $(this),
            data, url, method,
            dataType  = $this.attr("data-type")  || ($.ajaxSettings && $.ajaxSettings.dataType);

        if ($this.is("form")) {
            method = $this.attr("method");
            url = $this.attr("action");
            data = $this.serializeArray();
        } else {
            method = $this.attr("data-method");
            url = $this.attr("href");
        }

        $.ajax({
            url: url + ".json",
            data: data,
            dataType: dataType,
            type: method || "GET",
            beforeSend: function(xhr, settings) {
                if (settings.dataType === undefined) {
                    xhr.setRequestHeader("accept", "*/*;q=0.5, " + settings.accepts.script);
                }
                $this.trigger("ajax:loading", xhr);
            },
            success: function(data, status, xhr) {
                $this.trigger("ajax:success", [data, status, xhr]);
            },
            error: function (xhr, status, error) {
                $this.trigger('ajax:failure', [xhr, status, error]);
            },
            complete: function (xhr, status) {
                $this.trigger('ajax:complete', [xhr, status]);

                // try parse response as JSON and extract flash-es
                var json = $.parseJSON(xhr.response);
                if (json && json.flash) {
                    _.each(json.flash, function(message, severity) {
                        $this.trigger("flash:" + severity, message);
                    });
                }
            }
        });

        // I don't like to return false from event listeners
        // but it's necessary to omit event listeners from
        // rails.js file
        return false;
    };
    var disableSubmitCallback = function(event) {
        $(this).find("input[type=submit]").attr("disabled", "disabled");
    };
    var enableSubmitCallback = function(event) {
        $(this).find("input[type=submit]").removeAttr("disabled");
    };
    var clearText = function(selector) {
        return function(event) {
            $(this).find(selector).val("");
        };
    };
    var loadResource = function(supervisionId, resourceId, resourceType, $resourceContainer, single) {
        var url;
        if (single) {
            url = PGS["supervision" + capitalize(resourceType) + "Path"](supervisionId, { partial: 1 });
        } else {
            url = PGS["supervision" + capitalize(resourceType) + "Path"](supervisionId, resourceId, { partial: 1 });
        }
        var onSuccess = function(data, status, xhr) {
            var $resource = $resourceContainer.find("#" + resourceType + "_" + resourceId);
            var $newResource = $(data);
            if ($resource.length) {
                $newResource.replaceAll($resource);
            } else {
                if (single) {
                    $resourceContainer.find("> ." + resourceType, $resourceContainer).remove();
                }
                $newResource.appendTo($resourceContainer).hide().show("fast");
            }
            setupRating($newResource);
            $newResource.find("[title]").tooltip();
        };
        $.get(url, [], onSuccess);
    };

    var setupRating = function($parentElement) {
        $parentElement.find("form:has(input[type=radio][id*=_rating_])").each(function(i, el) {
            var $this = $(this);
            $this.find("input[type=radio][id*=_rating_]").rating({
                required: true,
                callback: function(value, link){ $this.submit(); }
            });
            $this.find("input[type=submit]").hide();
        });
    };

    var setupForm = function($formElement) {
        $formElement.find("form")
            .live({
                "submit": asyncSubmitCallback,
                "ajax:loading": disableSubmitCallback,
                "ajax:success": enableSubmitCallback,
                "ajax:failure": enableSubmitCallback
            });
        var hideForm = function() {
            $formElement.hide("fast");
        };
        var showForm = function() {
            $formElement.show("fast");
        };
        $formElement.find("a.discard")
            .live({
                "click": asyncSubmitCallback,
                "ajax:loading": hideForm,
                //"ajax:success": showForm,
                "ajax:failure": showForm
            });
    };

    var setupQuestionsPart = function($parent, supervisionId) {
        var $questions = $parent.find(".questions_part"),
            $questionsList = $questions.find(".list"),
            $newQuestionForm = $questions.find(".form"),
            $newAnswerForm = $questions.find(".answer:has('.new_answer')");
        var onNewQuestion = function(event, message) {
            loadResource(supervisionId, message.id, "question", $questionsList);
        };
        var onNewAnswer = function(event, message) {
            loadResource(supervisionId, message.question_id, "question", $questionsList);
        };

        $newQuestionForm.live("ajax:loading", clearText("#question_content"));
        setupForm($newQuestionForm);
        setupForm($newAnswerForm);

        $parent.bind({
            "newQuestion": onNewQuestion,
            "newAnswer": onNewAnswer
        });
    };
    var setupIdeasPart = function($parent, supervisionId) {
        var $ideas = $parent.find(".ideas_part"),
            $ideasList = $ideas.find(".list"),
            $newIdeaForm = $ideas.find(".form"),
            $editIdeaForm = $ideas.find(".idea:has('.edit_idea')");

        var onNewIdea = function(event, message) {
            loadResource(supervisionId, message.id, "idea", $ideasList);
        };

        $newIdeaForm.live("ajax:loading", clearText("#idea_content"));
        setupForm($newIdeaForm);
        setupForm($editIdeaForm);

        $parent.bind({
            "newIdea": onNewIdea
        });
    };
    var setupIdeasFeedbackPart = function($parent, supervisionId) {
        var $ideasFeedbacks = $parent.find(".ideas_feedback_part"),
            $ideasFeedbacksList = $ideasFeedbacks.find(".list");
        var onNewIdeasFeedback = function(event, message) {
            loadResource(supervisionId, message.id, "ideas_feedback", $ideasFeedbacksList, "single");
        };

        setupForm($ideasFeedbacks.find(".form"));

        $parent.bind({
            "newIdeasFeedback": onNewIdeasFeedback
        });
    };
    var setupSolutionsPart = function($parent, supervisionId) {
        var $solutions = $parent.find(".solutions_part"),
            $solutionsList = $solutions.find(".list"),
            $newSolutionForm = $solutions.find(".form"),
            $editSolutionForm = $solutions.find(".solution:has('.edit_solution')");
        var onNewSolution = function(event, message) {
            loadResource(supervisionId, message.id, "solution", $solutionsList);
        };

        $newSolutionForm.live("ajax:loading", clearText("#solution_content"));
        setupForm($newSolutionForm);
        setupForm($editSolutionForm);

        $parent.bind({
            "newSolution": onNewSolution
        });
    };
    var setupSolutionsFeedbackPart = function($parent, supervisionId) {
        var $solutionsFeedbacks = $parent.find(".solutions_feedback_part"),
            $solutionsFeedbacksList = $solutionsFeedbacks.find(".list");
        var onNewSolutionsFeedback = function(event, message) {
            loadResource(supervisionId, message.id, "solutions_feedback", $solutionsFeedbacksList, "single");
        };

        setupForm($solutionsFeedbacks.find(".form"));

        $parent.bind({
            "newSolutionsFeedback": onNewSolutionsFeedback
        });
    };
    var setupSupervisionFeedbackPart = function($parent, supervisionId) {
        var $supervisionFeedbacks = $parent.find(".supervision_feedbacks_part"),
            $supervisionFeedbacksList = $supervisionFeedbacks.find(".list"),
            $newSupervisionFeedbackForm = $supervisionFeedbacks.find(".form");

        var onNewSupervisionFeedback = function(event, message) {
            loadResource(supervisionId, message.id, "supervision_feedback", $supervisionFeedbacksList);
        };

        $newSupervisionFeedbackForm.live({
            "ajax:success": function() { $newSupervisionFeedbackForm.hide("fast"); }
        });
        setupForm($newSupervisionFeedbackForm);

        $parent.bind({
            "newSupervisionFeedback": onNewSupervisionFeedback
        });
    };

    var setupStatusbar = function($parent) {
        var $statusbar = $parent.find(".supervision_statusbar");
        var onSupervisionUpdate = function(event, message) {
            $statusbar.find(".current_state").removeClass("current_state");
            $statusbar.find("[data-state-name="+message.state+"]").addClass("current_state");
        };

        $parent.bind({
            "supervisionUpdate": onSupervisionUpdate
        });
    };

    var setupMembershipsPart = function($parent) {
        var $membershipsList = $parent.find(".members-part .members-list");
        var onSupervisionMembership = function(event, message) {
            if (message.status === "created") {
                var newMember = $("<li>", { "class": "user supervision-member", id: "user_" + message.user.id });
                newMember.append($("<img>", { "class": "gravatar", width: "50", height: "50", src: message.user.avatar_url + "?rating=PG&size=50" }));
                newMember.append($("<span>", { "class": "name", text: message.user.name }));
                $membershipsList.append(newMember);
            } else if (message.status === "destroyed") {
                $membershipsList.find("#user_" + message.user.id).remove();
            }
        };

        $parent.bind({
            "supervisionMembership": onSupervisionMembership
        });
    };

    $.fn.supervisionRoom = function() {
        return this.each(function() {
            var $this = $(this),
                supervisionState = $this.data("supervision-state");
                supervisionId = $this.attr("id").replace("supervision_", "");
            var messages = $this.data("supervision-state-transitions");

            setupRating($this);
            setupQuestionsPart($this, supervisionId);
            setupIdeasPart($this, supervisionId);
            setupIdeasFeedbackPart($this, supervisionId);
            setupSolutionsPart($this, supervisionId);
            setupSolutionsFeedbackPart($this, supervisionId);
            setupSupervisionFeedbackPart($this, supervisionId);
            setupStatusbar($this);
            setupMembershipsPart($this);

            $this.bind({
                "supervisionUpdate": function(event, message) {
                    var oldState = supervisionState,
                        newState = message.state;
                    $this.find("[data-show-in-state]").hide();
                    $this.find("[data-show-in-state~=" + newState + "]").show("fast")
                        .find(".form").show();

                    if (messages[oldState] && messages[oldState][newState]) {
                        $this.trigger("flash:notice", messages[oldState][newState]);
                    }

                    supervisionState = newState;
                }
            });

            $this.trigger("supervisionUpdate", { state: supervisionState });
            $this.find("[title]").tooltip();
        });
    };
})(jQuery);
