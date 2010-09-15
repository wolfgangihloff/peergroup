jQuery(document).ready(function($) {

  $.fn.chat = function() {
    this.each(function() {
      var container = this;
      var lastUpdate = $('.timestamp', container).text();
      var chatUpdateUrl = $('form.edit_chat_update', container).attr('action');
      var chatRoomUrl = chatUpdateUrl.replace(/\/chat_updates.+/, '');
      var chatUpdates = $(".chat_updates", container);
      var activeUpdateId;

      function scrollUpdates() {
        chatUpdates.animate({ scrollTop: chatUpdates.attr("scrollHeight") }, 500);
      };

      scrollUpdates();


      function updateChat() {
        $('form.edit_chat_update', container).ajaxSubmit({
          data: {update_type: 'update', last_update: lastUpdate},
          dataType: 'json',
          success: function(data) {
            $.each(data.feeds, function(i, feed) {
              if(document.getElementById(feed.id) == null) {
                chatUpdates.append(feed.update);
                $('#' + feed.id, container).hide().fadeIn(500);
                scrollUpdates();
              } else {
                $('#' + feed.id, container).replaceWith(feed.update);
              };
            });

            $('#' + activeUpdateId, container).addClass('active');

            lastUpdate = data.timestamp;
            setTimeout(updateChat, 1000);
          }
        });

        $.get(chatRoomUrl + '/chat_users', function(data) {
          $('.chatting_users', container).replaceWith(data);
        });

        $.get(chatRoomUrl + '/chat_rules', function(data) {
          $('.rules', container).replaceWith(data);
        });
      };

      $('form.edit_chat_update', container).live('submit', function() {
        $(this).ajaxSubmit({
          clearForm: true,
          target: $('form.edit_chat_update', container),
          replaceTarget: true,
          success: function() {
            $('#chat_update_message').focus();
          }
        });
        return false;
      });

      $('.chat_update.root', container).live('click', function() {
        var chatUpdate = $(this);
        $('.chat_update', container).removeClass('active');
        chatUpdate.addClass('active');
        activeUpdateId = chatUpdate.attr('id');
        var id = $('.reply a', chatUpdate).attr('href').replace('#', '');
        $('form.edit_chat_update #parent_id', container).val(id);
      });

      setTimeout(updateChat, 1000);
    });
  };

  $('#chat').chat();
});

