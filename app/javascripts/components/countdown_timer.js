(function ($) {

    $.fn.countdownTimer = function (options) {
        options = $.extend({
            rows: 4,
            cols: 7,
            time: 1700,
            gridSize: 60,
            stopAtEnd: true,
            displayTime: false,
            displaySeconds: 60,
            onStart: function () {},
            onStop: function () {}
        }, options);

        return $(this).each(function (i, element) {
            var seconds, interval
                row = 0,
                col = 0;

            seconds = options.displaySeconds;
            start();
            function tick() {
                var verticalPosition, horizontalPosition, position;

                if (row > options.rows) {
                    row = 0;
                    col += 1;
                }

                if (col > options.cols || seconds === 0) {
                    if (options.stopAtEnd) {
                        stop();
                    }
                    col = 0;
                    seconds = options.displaySeconds;
                }
                verticalPosition = col * options.gridSize * -1;
                horizontalPosition = row * options.gridSize * -1;
                position = horizontalPosition + "px " + verticalPosition + "px";
                $(element).css("background-position", position);

                if (options.displayTime) {
                    $(element).text(--seconds);
                }
                ++row;
            };

            function start() {
                options.onStart();
                interval = setInterval(function () {
                    tick(options);
                }, options.time);
            };

            function stop() {
                options.onStop();
                clearInterval(interval);
            };

            if (options.displayTime) {
                $(element).html(seconds);
            }
        });
    };

})(jQuery);
