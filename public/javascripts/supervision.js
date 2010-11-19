jQuery(document).ready(function($) {

  function setupNotifications(selector, resource) {

    if($(selector).length == 0) return false;

    function updateList() {
      $.get(document.location + '&partial=true', function(data) {

        if($('form#new_' + resource).length == 0) {
          // Problem owner scenario
          $('li.' + resource, data).each(function() {
            if($('#' + $(this).attr('id')).length == 0) {
              $(selector).append(this);
              $('#' + $(this).attr('id')).hide().fadeIn();
            }
          });
        } else {
          // Non problem owner scenario
          $(selector).replaceWith(data);
        }

        if($('#next_step', data).length > 0) {
          document.location = '';
        }
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

