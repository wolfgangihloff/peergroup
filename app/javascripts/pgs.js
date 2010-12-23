(function() {
    var root = this;
    var usersCache = {};
    var PGS = {
        userInfo: function(userId, callback) {
            if (usersCache[userId]) {
                callback.call({}, userId, usersCache[userId]);
            } else {
                var onSuccess = function(data, textStatus, xhr) {
                    usersCache[userId] = data.user;
                    callback.call({}, userId, usersCache[userId]);
                };
                $.get(PGS.userPath(userId), [], onSuccess, "json");
            }
        },
                    
        userPath: function(userId) {
            return "/users/" + userId;
        }
    };
 
    this.PGS = PGS;
})();
