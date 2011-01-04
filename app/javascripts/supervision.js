(function($){
    $.fn.supervisionRoom = function() {
        return this.each(function() {
            var $this = $(this);
            var supervisionState = $this.data("supervision-state");
            var supervisionId = $this.attr("id").replace("supervision_", "");
            var $topics = $this.find(".topics");

            var onTopicState = function() {
                var $newTopicForm = $topics.find("#new_topic");

                if ($newTopicForm.length) {
                    $newTopicForm.attr("action", $newTopicForm.attr("action") + ".js");
                    $newTopicForm.live("submit", function(event) {
                        $(this).callRemote();
                        event.preventDefault();
                    });
                    $newTopicForm.bind({
                        "ajax:loading": function(){ $newTopicForm.find("input[type=submit]").attr("disabled", "disabled"); },
                        "ajax:success": function(){ $newTopicForm.remove(); }
                    });
                }

                console.log("onTopicState");
            };

            var stateChangeCallbacks = {
                "topic": onTopicState
            };
            var onNewTopic = function(event, message) {
                var url = PGS.supervisionTopicPath(supervisionId, message.id, { partial: 1 });
                var onSuccess = function(data, status, xhr) {
                    var newTopic = $(data);
                    $topics.append(newTopic);
                    newTopic.hide();
                    newTopic.show("fast");
                };
                $.get(url, [], onSuccess);
            };

            $this.bind({
                "newTopic": onNewTopic
            });

            stateChangeCallbacks[supervisionState]();
        });
    };
})(jQuery);
if (0) {
jQuery(document).ready(function($) {

  function setupNotifications(selector, resource) {

    if($(selector).length == 0) return false;

    function updateList() {
      $.get(document.location + '?partial=true', function(data) {

        if($('form#new_' + resource).length == 0) {
          // Problem owner scenario
          $('li.' + resource, $(data)).each(function() {
            $('.no_' + resource).remove();
            if($('#' + $(this).attr('id')).length == 0) {
              $(selector).append(this);
              $('input[type=radio].star').rating();
              $('#' + $(this).attr('id')).hide().fadeIn();
            }
          });
        } else {
          // Non problem owner scenario
          $(selector).replaceWith(data);
          $('input[type=radio].star').rating();
        }

        var currentStep = $('#current_step', $(data));
      });
    }

  }

});
}
