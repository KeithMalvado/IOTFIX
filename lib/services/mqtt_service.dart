import 'dart:async';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttMessage {
  final String topic;
  final String payload;
  MqttMessage(this.topic, this.payload);
}

class _ClientWrapper {
  final MqttServerClient client;
  final StreamController<MqttMessage> controller = StreamController.broadcast();
  StreamSubscription? _updatesSub;

  _ClientWrapper(this.client) {
    _updatesSub = client.updates?.listen((List<MqttReceivedMessage> events) {
      for (var ev in events) {
        final rec = ev.payload as MqttPublishMessage;
        final payloadString =
            MqttPublishPayload.bytesToStringAsString(rec.payload.message);
        controller.add(MqttMessage(ev.topic, payloadString));
      }
    });
  }

  Stream<MqttMessage> get stream => controller.stream;

  void dispose() {
    _updatesSub?.cancel();
    controller.close();
    try {
      client.disconnect();
    } catch (_) {}
  }
}

class MqttManager {
  MqttManager._private();
  static final MqttManager instance = MqttManager._private();

  final Map<String, _ClientWrapper> _clients = {};
  final Map<String, MqttServerClient> _rawClients = {};
  final StreamController<MqttMessage> _globalController =
      StreamController.broadcast();

  Stream<MqttMessage> get messagesStream => _globalController.stream;

  Future<void> connectIfNeeded({
    required String broker,
    required String clientId,
    required String username,
    required String password,
    int port = 1883,
    bool secure = false,
  }) async {
    if (_clients.containsKey(broker)) return;

    final client = MqttServerClient(broker, clientId);
    client.port = port;
    client.secure = secure;
    client.logging(on: false);
    client.keepAlivePeriod = 20;

    final connMess = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .authenticateAs(username, password)
        .withWillQos(MqttQos.atLeastOnce);
    client.connectionMessage = connMess;

    try {
      await client.connect();
    } catch (e) {
      client.disconnect();
      rethrow;
    }

    if (client.connectionStatus?.state == MqttConnectionState.connected) {
      final wrap = _ClientWrapper(client);
      _clients[broker] = wrap;
      _rawClients[broker] = client;
      wrap.stream.listen((m) => _globalController.add(m));
    } else {
      client.disconnect();
      throw Exception('Cannot connect to $broker - ${client.connectionStatus}');
    }
  }

  void subscribe(String topic, {String? broker}) {
    if (broker != null) {
      final client = _rawClients[broker];
      client?.subscribe(topic, MqttQos.atMostOnce);
      return;
    }
    for (var client in _rawClients.values) {
      client.subscribe(topic, MqttQos.atMostOnce);
    }
  }

  void unsubscribe(String topic, {String? broker}) {
    if (broker != null) {
      final client = _rawClients[broker];
      client?.unsubscribe(topic);
      return;
    }
    for (var client in _rawClients.values) {
      client.unsubscribe(topic);
    }
  }

  Future<void> publish(String topic, String payload,
      {String? broker, MqttQos qos = MqttQos.atLeastOnce}) async {
    MqttServerClient? client;
    if (broker != null) client = _rawClients[broker];
    client ??= _rawClients.values.isEmpty ? null : _rawClients.values.first;
    if (client == null)
      throw Exception('No MQTT client available. Call connectIfNeeded first.');

    final builder = MqttClientPayloadBuilder();
    builder.addString(payload);
    client.publishMessage(topic, qos, builder.payload!);
  }

  void disposeBroker(String broker) {
    final wrap = _clients.remove(broker);
    wrap?.dispose();
    _rawClients.remove(broker);
  }

  void disposeAll() {
    for (var b in _clients.keys.toList()) disposeBroker(b);
    _globalController.close();
  }
}
