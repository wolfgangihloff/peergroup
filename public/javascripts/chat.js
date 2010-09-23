jQuery(document).ready(function($) {

  $.fn.chat = function() {
    this.each(function() {
      var container = this;
      var chatUpdates = $(".chat_updates", container);
      var activeChatUpdateElementId;

      //////////////// View helper
      var ViewHelper = {
        scrollUpdates: function(callback) {
          var scroll = chatUpdates.attr('clientHeight')  + chatUpdates.attr('scrollTop') == chatUpdates.attr('scrollHeight');
          if(callback) callback();
          if(!callback || scroll) {
            chatUpdates.animate({ scrollTop: chatUpdates.attr("scrollHeight") }, 500);
          }
        }
      };

      var UrlHelper = function() {
        var base = $('form.edit_chat_update', container).attr('action').replace(/\/chat_updates.+/, '');
        return {
          chatRooms: base,
          chatUpdates: base + '/chat_updates',
          newChatUpdate: base + '/chat_updates/new',
          chatRules: base + '/chat_rules',
          chatUsers: base + '/chat_users'
        };
      }();

      //////////////// Chat updates controller
      var ChatUpdatesController = function() {
        var lastUpdate = $('.timestamp', container).text();

        function processChatFeed(data) {
          ViewHelper.scrollUpdates(function() {
            $.each(data.feeds, function(i, feed) {
              if(document.getElementById(feed.id) == null) {
                $('a.new_message', container).before(feed.update);
                $('#' + feed.id, container).hide().fadeIn(500);
              } else {
                $('#' + feed.id, container).replaceWith(feed.update);
              };
            });

            $('#' + activeChatUpdateElementId, container).addClass('active');
          });


          lastUpdate = data.timestamp;
          setTimeout(queryChatFeed, 1000);
        }

        function queryChatFeed() {
          $.get(UrlHelper.chatUpdates, {last_update: lastUpdate}, processChatFeed, 'json');
        }

        setTimeout(queryChatFeed, 1000);
      }();

      //////////////// MessagesController
      var MessagesController = function() {
        var activeChatUpdateId;
        var dirty = false;

        // As form is reloaded it must be lazy
        function form() {
          return $('form.edit_chat_update', container);
        }

        function submitMessage(callback, rejectBlank, updateOnly) {
          var data = updateOnly ? {update_type: "update"} : {}
          dirty = false;

          function submit() {
            form().ajaxSubmit({
              success: function() {
                if(callback) callback();
              },
              data: data
            });
          }

          if(rejectBlank) {
            if($('#chat_update_message', form()).val().length < 1) {
              if(callback) callback();
            } else {
              submit();
            }
          } else {
            submit();
          }
        }

        function getForm(parentID) {
          $.get(UrlHelper.newChatUpdate, {parent_id: parentID}, function(data) {
            form().replaceWith(data);
            $('#chat_update_message').focus();
          });
        }

        function pushUpdates() {
          if(dirty) {
            submitMessage(null, null, true);
            dirty = false;
          }
          setTimeout(pushUpdates, 1000);
        }
        setTimeout(pushUpdates, 1000);

        $('#chat_update_message', form()).live('keyup', function() {
          dirty = true;
        });

        form().live('submit', function() {
          submitMessage(function() {
            getForm(activeChatUpdateId);
          });
          return false;
        });

        $('.chat_update.root', container).live('click', function() {
          var chatUpdate = $(this);
          activeChatUpdateId = $('.reply a', chatUpdate).attr('href').replace('#', '');
          activeChatUpdateElementId = chatUpdate.attr('id');

          submitMessage(function() {
            $('.chat_update').removeClass('active');
            getForm(activeChatUpdateId);
          }, true);
        });

        $('.new_message', container).click(function() {
          activeChatUpdateElementId = activeChatUpdateId = undefined;
          submitMessage(null, true);
          getForm();
        });

      }();

      // Chat users
      function updateChatUsers() {
        $.get(UrlHelper.chatUsers, function(data) {
          $('.chatting_users', container).replaceWith(data);
        });
        setTimeout(updateChatUsers, 1000);
      }

      setTimeout(updateChatUsers, 1000);

      // Active rules
      function updateChatRules() {
        $.get(UrlHelper.chatRules, function(data) {
          $('.rules', container).replaceWith(data);
        });
        setTimeout(updateChatRules, 1000);
      }

      setTimeout(updateChatRules, 1000);

      ViewHelper.scrollUpdates();
    });
  }

  $('#chat').chat();
});

