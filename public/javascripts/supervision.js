jQuery(document).ready(function($) {
  if($('#topic_questions').length > 0) {

    function updateList() {
      $.get(document.location + '&partial=true', function(data) {

        if($('form#new_question').length == 0) {
          // Problem owner scenario

          $('li.question', data).each(function() {
            if($('#' + $(this).attr('id')).length == 0) {
              $('#topic_questions').append(this);
              $('#' + $(this).attr('id')).hide().fadeIn();
            }
          });
        }

      });
      setTimeout(updateList, 1000);
    }

    setTimeout(updateList, 1000);

  }
});

