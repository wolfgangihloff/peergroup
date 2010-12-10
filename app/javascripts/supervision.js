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
        if(document.pgs.supervision_step != currentStep.attr('data-step'))
          window.location.reload(true);

        setTimeout(updateList, 1000);
      });
    }

    setTimeout(updateList, 1000);
  }

  if(document.pgs.controller == 'TopicQuestionsController') {
    setupNotifications('#topic_questions', 'question');
  }

  if(document.pgs.controller == 'IdeasController') {
    setupNotifications('#ideas', 'idea');
  }

  if(document.pgs.controller == 'SolutionsController') {
    setupNotifications('#solutions', 'solution');
  }

});

