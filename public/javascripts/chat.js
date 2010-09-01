jQuery(document).ready(function($) {

  $.fn.chat = function() {
    this.each(function() {
      var container = this;
      var lastUpdate = $('.timestamp', container).text();
      var chatUpdateUrl = $('form.new_chat_update', container).attr('action');

      function updateChat() {
        $.getJSON(chatUpdateUrl, {last_update: lastUpdate}, function(data) {
          $.each(data.feeds, function(i, feed) {
            if(document.getElementById(feed.id) == null) {
              $(".chat_updates", container).append(feed.update);
            };
          });

          lastUpdate = data.timestamp;
          setTimeout(updateChat, 1000);
        });
      };

      setTimeout(updateChat, 1000);
    });
  };

  $('#chat').chat();
});

