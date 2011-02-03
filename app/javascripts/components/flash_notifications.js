(function($, undefined){

$.widget("ui.flashnotifications", {
    options: {
        displayTime: 30000,
        animate: false,
        animateDuration: 200,
        animateEasing: "linear"
    },
    _create: function() {
        var self = this,
            options = this.options;

        self.element.addClass("ui-flash");

        var currentFlashElements = self.element.find(".flash");

        if (self.options.displayTime) {
            setTimeout(function() { currentFlashElements.remove(); }, self.options.displayTime);
        }
    },
    destroy: function() {
        this.element
            .removeClass("ui-flash");

        return this;
    },
    notice: function(message) {
        this._showMessage("notice", message);
        return this;
    },
    error: function(message) {
        this._showMessage("error", message);
        return this;
    },
    _showMessage: function(severity, message) {
        var messageElement = $("<div>", { "class": "flash " + severity, text: message });
        var self = this;

        self.element.append(messageElement);
        if (self.options.animate) {
            messageElement.hide().show(self.options.animateDuration, self.options.animateEasing);
        }

        if (self.options.displayTime) {
            var hideFunction = function() { messageElement.remove(); };
            if (self.options.animate) {
                var removeFunction = hideFunction;
                hideFunction = function() { messageElement.hide(self.options.animateDuration, self.options.animateEasing, removeFunction); };
            }
            setTimeout(hideFunction, self.options.displayTime);
        }
    }
});

})(jQuery);
