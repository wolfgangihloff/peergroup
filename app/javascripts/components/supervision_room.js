(function($){
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

    var makeSupervisionContext = function($parent, supervisionId) {
        var context = {};

        context.updateMessages = $parent.data("supervision-updates");
        /*
         * addResource(resource, content, $container, callback = undefined)
         *   callback(resource, $(content), $container)
         */
        context.addResource = function(resource, content, $container, callback) {
            var $previousContent = $container.find("#" + resource.type + "_" + resource.id),
                $content = $(content);
            if ($previousContent.length) {
                $content.replaceAll($previousContent);
            } else {
                if (resource.single) {
                    $container.find("> ." + resource.type).remove();
                }
                $content.appendTo($container).hide().show("fast");
            }
            setupRating($content);
            $content.find("[title]").tooltip();
            if (callback) {
                callback.call(this, resource, $content, $container, $previousContent);
            }
            return this;
        };
        /*
         * loadResource(resource, $container, callback = undefined)
         */
        context.loadResource = function(resource, $container, callback) {
            var that = this;
            var url;
            if (resource.single) {
                url = PGS["supervision" + Util.capitalize(resource.type) + "Path"](supervisionId, { partial: 1 });
            } else {
                url = PGS["supervision" + Util.capitalize(resource.type) + "Path"](supervisionId, resource.id, { partial: 1 });
            }
            var onSuccess = function(data, status, xhr) {
                that.addResource(resource, $(data), $container, callback);
            };
            $.get(url, [], onSuccess);
            return this;
        };
        /*
         * setupQuestionsPart()
         */
        context.setupQuestionsPart = function() {
            var that = this;
            var $questions = $parent.find(".questions_part"),
                $questionsList = $questions.find(".list"),
                $newQuestionForm = $questions.find(".form"),
                $newAnswerForm = $questions.find(".answer:has('.new_answer')");

            var onNewQuestion = function(event, message) {
                var resource = { type: "question", id: message.id };
                that.loadResource(resource, $questionsList);
            };
            var onNewAnswer = function(event, message) {
                var resource = { type: "question", id: message.question_id };
                that.loadResource(resource, $questionsList);
            };

            $newQuestionForm.live("ajax:loading", clearText("#question_content"));
            setupForm($newQuestionForm);
            setupForm($newAnswerForm);

            $parent.bind({
                "supervision:question": onNewQuestion,
                "supervision:answer": onNewAnswer
            });
            return this;
        };
        /*
         * setupIdeasPart()
         */
        context.setupIdeasPart = function() {
            var that = this;
            var $ideas = $parent.find(".ideas_part"),
                $ideasList = $ideas.find(".list"),
                $newIdeaForm = $ideas.find(".form"),
                $editIdeaForm = $ideas.find(".idea:has('.edit_idea')");

            var afterAdd = function(resource, $content, $container, $previousContent) {
                if ($previousContent.length) {
                    $parent.trigger("flash:notice", that.updateMessages["idea"]);
                }
            };
            var onNewIdea = function(event, message) {
                var resource = { type: "idea", id: message.id };
                that.loadResource(resource, $ideasList, afterAdd);
            };

            $newIdeaForm.live("ajax:loading", clearText("#idea_content"));
            setupForm($newIdeaForm);
            setupForm($editIdeaForm);

            $parent.bind({
                "supervision:idea": onNewIdea
            });
            return this;
        };
        /*
         * setupIdeasFeedbackPart()
         */
        context.setupIdeasFeedbackPart = function() {
            var that = this;
            var $ideasFeedbacks = $parent.find(".ideas_feedback_part"),
                $ideasFeedbacksList = $ideasFeedbacks.find(".list");

            var onNewIdeasFeedback = function(event, message) {
                var resource = { type: "ideas_feedback", id: message.id, single: true };
                that.loadResource(resource, $ideasFeedbacksList);
            };

            setupForm($ideasFeedbacks.find(".form"));

            $parent.bind({
                "supervision:ideasFeedback": onNewIdeasFeedback
            });
            return this;
        };
        /*
         * setupSolutionsPart()
         */
        context.setupSolutionsPart = function() {
            var that = this;
            var $solutions = $parent.find(".solutions_part"),
                $solutionsList = $solutions.find(".list"),
                $newSolutionForm = $solutions.find(".form"),
                $editSolutionForm = $solutions.find(".solution:has('.edit_solution')");

            var afterAdd = function(resource, $content, $container, $previousContent) {
                if ($previousContent.length) {
                    $parent.trigger("flash:notice", that.updateMessages["solution"]);
                }
            };
            var onNewSolution = function(event, message) {
                var resource = { type: "solution", id: message.id };
                that.loadResource(resource, $solutionsList, afterAdd);
            };

            $newSolutionForm.live("ajax:loading", clearText("#solution_content"));
            setupForm($newSolutionForm);
            setupForm($editSolutionForm);

            $parent.bind({
                "supervision:solution": onNewSolution
            });
            return this;
        };
        /*
         * setupSolutionsFeedbackPart()
         */
        context.setupSolutionsFeedbackPart = function() {
            var that = this;
            var $solutionsFeedbacks = $parent.find(".solutions_feedback_part"),
                $solutionsFeedbacksList = $solutionsFeedbacks.find(".list");

            var onNewSolutionsFeedback = function(event, message) {
                var resource = { type: "solutions_feedback", id: message.id, single: true };
                that.loadResource(resource, $solutionsFeedbacksList);
            };

            setupForm($solutionsFeedbacks.find(".form"));

            $parent.bind({
                "supervision:solutionsFeedback": onNewSolutionsFeedback
            });
            return this;
        };
        /*
         * setupSupervisionFeedbackPart()
         */
        context.setupSupervisionFeedbackPart = function() {
            var that = this;
            var $supervisionFeedbacks = $parent.find(".supervision_feedbacks_part"),
                $supervisionFeedbacksList = $supervisionFeedbacks.find(".list"),
                $newSupervisionFeedbackForm = $supervisionFeedbacks.find(".form");

            var onNewSupervisionFeedback = function(event, message) {
                var resource = { type: "supervision_feedback", id: message.id };
                that.loadResource(resource, $supervisionFeedbacksList);
            };

            $newSupervisionFeedbackForm.live({
                "ajax:success": function() { $newSupervisionFeedbackForm.hide("fast"); }
            });
            setupForm($newSupervisionFeedbackForm);

            $parent.bind({
                "supervision:supervisionFeedback": onNewSupervisionFeedback
            });
            return this;
        };
        /*
         * setupStatusbar()
         */
        context.setupStatusbar = function() {
            var $statusbar = $parent.find(".supervision_statusbar");
            var onSupervisionUpdate = function(event, message) {
                $statusbar.find(".current_step").removeClass("current_step");
                $statusbar.find("[data-state-name="+message.state+"]").addClass("current_step");
            };

            $parent.bind({
                "supervision:update": onSupervisionUpdate
            });
            return this;
        };

        var chatMemberTemplate = _.template(
            "<li class=\"user supervision-member\" id=\"user_<?= id ?>\"" +
              "<img class=\"gravatar\" width=\"50\" height=\"50\" src=\"<?= avatar_url ?>?rating=PG&size=50\" />" +
              "<span class=\"name\"><?= name ?></span>" +
            "</li>"
        );
        /*
         * setupMembershipsPart()
         */
        context.setupMembershipsPart = function() {
            var $membershipsList = $parent.find(".members-part .members-list");
            var onSupervisionMembership = function(event, message) {
                if (message.status === "created") {
                    var newMember = $(chatMemberTemplate(message.user));
                    $membershipsList.append(newMember);
                } else if (message.status === "destroyed") {
                    $membershipsList.find("#user_" + message.user.id).remove();
                }
            };

            $parent.bind({
                "supervision:membership": onSupervisionMembership
            });
            return this;
        };
        return context;
    };

    $.fn.supervisionRoom = function() {
        return this.each(function() {
            var $this = $(this),
                supervisionState = $this.data("supervision-state"),
                supervisionId = $this.attr("id").replace("supervision_", "");
            var messages = $this.data("supervision-state-transitions");

            setupRating($this);

            var supervisionContext = makeSupervisionContext($this, supervisionId);
            supervisionContext
                .setupQuestionsPart()
                .setupIdeasPart()
                .setupIdeasFeedbackPart()
                .setupSolutionsPart()
                .setupSolutionsFeedbackPart()
                .setupSupervisionFeedbackPart()
                .setupStatusbar($this)
                .setupMembershipsPart($this);

            $this.bind({
                "supervision:update": function(event, message) {
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
            $this.trigger("supervision:update", { state: supervisionState });
            $this.find("[title]").tooltip();
        });
    };
})(jQuery);
