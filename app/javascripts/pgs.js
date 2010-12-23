(function() {
    var root = this;
    var usersCache = {};
    var path = function(pathComponents, options) {
        var p = "/" + pathComponents.join("/");
        if (options.format) {
            p = p + "." + options.format;
        }
        return p;
    };

    var PGS = {
        userInfo: function(userId, callback) {
            if (usersCache[userId]) {
                callback.call({}, userId, usersCache[userId]);
            } else {
                var onSuccess = function(data, textStatus, xhr) {
                    usersCache[userId] = data.user;
                    callback.call({}, userId, usersCache[userId]);
                };
                $.get(PGS.userPath(userId, { format: "json" }), [], onSuccess, "json");
            }
        },
                    
        userPath: function(userId, options) {
            return path(["users", userId], options);
        }
    };
 
    this.PGS = PGS;
})();
