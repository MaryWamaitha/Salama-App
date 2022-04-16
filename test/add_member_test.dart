import 'package:salama/models/add_member.dart';
import 'package:test/test.dart';


void main() {
  group('Testing App Provider', () {
    var addition = addMember();

    test('A new user should be added', () {
      String number = 'Joy';
      addition.addMembers(number);
      expect(users.contains(number), true);
    });
  });
}