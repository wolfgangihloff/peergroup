(function ($) {
  var seconds, element, interval,
      _options = {},
      row = 0,
      col = 0;
  $.defaults = {
    rows: 4, 
    cols: 7,
    time: 1000,
    gridSize: 60,
    stopAtEnd: true,
    displayTime: true,
    displaySeconds: 35,
    onStart: function (o){},
    onStop: function (){}
  },

  $.tick = function () {
    if (row > _options.rows ) {
      row = 0;
      col += 1;
    }
    if (col > _options.cols || seconds === 0) {
      if (_options.stopAtEnd) {
        $.stop();
      }
        col = 0;
        seconds = _options.displaySeconds;
    }
    verticalPosition = col * _options.gridSize * -1;
    horizontalPosition = row * _options.gridSize * -1;
    position = horizontalPosition + "px " + verticalPosition + "px";
    $(element).css("background-position", position);
    if (_options.displayTime) {
      $(element).text(--seconds);
    }
    ++row;
  };

  $.start = function () {
    _options.onStart();
    interval = setInterval(function(){ $.tick(_options) }, _options.time);
  };

  $.stop = function () {
    _options.onStop();
    clearInterval(interval);
  }

  $.fn.countdown_timer = function (options) {
    element = this;
    $.extend (_options, $.defaults, options);
    seconds = _options.displaySeconds;
    if ( _options.displayTime) {
      $(element).html(seconds);
    }
    return $;
  };
})(jQuery);