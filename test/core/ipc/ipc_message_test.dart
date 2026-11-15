import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_whatsapp/core/ipc/ipc_message.dart';

void main() {
  group('IpcRequest', () {
    test('serializes and deserializes correctly', () {
      const request = IpcRequest(
        id: 'req_1',
        action: 'get_status',
        params: {'filter': 'active'},
      );

      final json = request.toJson();
      expect(json['id'], 'req_1');
      expect(json['action'], 'get_status');
      expect(json['params'], {'filter': 'active'});

      final parsed = IpcRequest.fromJson(json);
      expect(parsed.id, 'req_1');
      expect(parsed.action, 'get_status');
      expect(parsed.params, {'filter': 'active'});
    });

    test('handles missing params', () {
      const request = IpcRequest(id: 'req_2', action: 'ping');
      final json = request.toJson();
      expect(json.containsKey('params'), isFalse);

      final parsed = IpcRequest.fromJson(json);
      expect(parsed.id, 'req_2');
      expect(parsed.action, 'ping');
      expect(parsed.params, isNull);
    });
  });

  group('IpcResponse', () {
    test('handles success response', () {
      const response = IpcResponse(
        id: 'req_1',
        result: {'status': 'connected'},
      );

      expect(response.isSuccess, isTrue);
      final json = response.toJson();
      expect(json['id'], 'req_1');
      expect(json['result'], {'status': 'connected'});
      expect(json.containsKey('error'), isFalse);

      final parsed = IpcResponse.fromJson(json);
      expect(parsed.id, 'req_1');
      expect(parsed.result, {'status': 'connected'});
      expect(parsed.error, isNull);
      expect(parsed.isSuccess, isTrue);
    });

    test('handles error response', () {
      const response = IpcResponse(
        id: 'req_2',
        error: 'Failed to pair device',
      );

      expect(response.isSuccess, isFalse);
      final json = response.toJson();
      expect(json['id'], 'req_2');
      expect(json['error'], 'Failed to pair device');

      final parsed = IpcResponse.fromJson(json);
      expect(parsed.id, 'req_2');
      expect(parsed.error, 'Failed to pair device');
      expect(parsed.isSuccess, isFalse);
    });
  });

  group('IpcEvent', () {
    test('serializes and deserializes event payload', () {
      const event = IpcEvent(
        event: 'qr_code',
        data: {'code': '2@abc...'},
      );

      final json = event.toJson();
      expect(json['event'], 'qr_code');
      expect(json['data'], {'code': '2@abc...'});

      final parsed = IpcEvent.fromJson(json);
      expect(parsed.event, 'qr_code');
      expect(parsed.data, {'code': '2@abc...'});
    });
  });
}
