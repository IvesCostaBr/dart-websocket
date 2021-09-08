import "dart:convert";
import 'dart:io';
import 'package:route/server.dart' show Router;



void handleWebSocket(WebSocket webSocket) {
  // Listen for incoming data. We expect the data to be a JSON-encoded String.
  webSocket
    .map((string)=> JSON.decode(string))
    .listen((json) {
      // The JSON object should contains a 'echo' entry.
      var echo = json['echo'];
      print("Message to be echoed: $echo");
      var response='{"response": "$echo"}';
      webSocket.add(response);
    }, onError: (error) {
      print('Bad WebSocket request');
    });
}


void main() {
  int port = 9223;

  HttpServer.bind(InternetAddress.LOOPBACK_IP_V4, port).then((server) {
    print("Search server is running on "
             "'http://${server.address.address}:$port/'");
    var router = new Router(server);
    // The client will connect using a WebSocket. Upgrade requests to '/ws' and
    // forward them to 'handleWebSocket'.
    router.serve('/ws')
      .transform(new WebSocketTransformer())
      .listen(handleWebSocket);
  });
}
