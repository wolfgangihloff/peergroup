var Util = {
    capitalize: function(str) {
        var result = "";
        var strParts = str.split("_");
        for (var i = 0; i < strParts.length; i++) {
            if (strParts[i].length > 1) {
                result += strParts[i].charAt(0).toUpperCase() + strParts[i].substring(1);
            } else {
                result += strParts[i].toUpperCase();
            }
        }
        return result;
    }
};

