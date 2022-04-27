import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:salama/models/add_member.dart';
import 'package:salama/Screens/create_screen1.dart';
import 'package:firebase_core/firebase_core.dart';

Widget createGroupScreen() {
  CreateGroup();
}


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  group('Create Group Tests', () {
    testWidgets('Testing Scrolling', (tester) async {
      await tester.pumpWidget(createGroupScreen());
      expect(find.text('Set up group Safe word ?'), findsOneWidget);
      // await tester.fling(find.byType(ListView), Offset(0, -200), 3000);
      // await tester.pumpAndSettle();
      // expect(find.text('Item 0'), findsNothing);
    });
  });
}