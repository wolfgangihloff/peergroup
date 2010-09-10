jQuery(document).ready(function($) {

  $.fn.chat = function() {
    this.each(function() {
      var container = this;
      var lastUpdate = $('.timestamp', container).text();
      var chatUpdateUrl = $('form.new_chat_update', container).attr('action');
      var chatUpdates = $(".chat_updates", container);

      function scrollUpdates() {
        chatUpdates.animate({ scrollTop: chatUpdates.attr("scrollHeight") }, 500);
      };

      scrollUpdates();

      function updateChat() {
        $.getJSON(chatUpdateUrl, {last_update: lastUpdate}, function(data) {
          $.each(data.feeds, function(i, feed) {
            if(document.getElementById(feed.id) == null) {
              chatUpdates.append(feed.update);
              $('#' + feed.id, container).hide().fadeIn(500);
              scrollUpdates();
            };
          });

          lastUpdate = data.timestamp;
          setTimeout(updateChat, 1000);

        });

        $.get(chatUpdateUrl.replace('chat_updates', 'chat_users'), function(data) {
          $('.chatting_users', container).replaceWith(data);
        });

        $.get(chatUpdateUrl.replace('chat_updates', 'chat_rules'), function(data) {
          $('.rules', container).replaceWith(data);
        });
      };

      $('form.new_chat_update', container).ajaxForm(function() {
        $('#chat_update_message').val('');
      });

      $('#chat_update_message').focus();

      setTimeout(updateChat, 1000);
    });
  };

  $('#chat').chat();
});

