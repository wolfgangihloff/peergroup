(function() {
    var socket = new io.Socket(null, { port: 8080 });
    socket.on("connect", function() {
        socket.send({ userId: Math.round(Math.random() * 100), token: "65536", chatRoom: "1" });
    });

    var authenticated = false;
    socket.on("message", function(message) {
        if (!authenticated) {
            if (message && message.status === "OK") {
                console.log("Authenticated");
                authenticated = true;
            } else {
                console.error(message);
            }
        } else {
            switch (message.type) {
            case "presence":
                if (message.action === "enter") {
                    console.log("User " + message.user + " enters");
                } else if (message.action === "exit") {
                    console.log("User " + message.user + " exits");
                }
                break;

            case "message": break;
            default: break;
            }
        }
    });
    socket.connect();
})();
