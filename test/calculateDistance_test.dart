import 'package:test/test.dart';
import 'package:salama/models/calculateDistance.dart';

void main() {
  group('Testing App Provider', () {
    var method = calculateDistance();

    test('distance should be calculated and boolean returned', () {
      var number = 35;
      var returned = method.trackingUser(5.6221, -0.17335, 5.6221003, -0.1733501, 1000);
      expect(returned, true);
    });
  });
}