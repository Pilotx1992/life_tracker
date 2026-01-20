import 'package:flutter_test/flutter_test.dart';
import 'package:life_tracker/core/services/app_lock_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppLockService', () {
    late AppLockService lockService;

    setUp(() {
      lockService = AppLockService.instance;
    });

    group('PIN Strength Detection', () {
      test('detects weak PIN with all same digits', () {
        expect(lockService.isPinWeak('1111'), isTrue);
        expect(lockService.isPinWeak('2222'), isTrue);
        expect(lockService.isPinWeak('0000'), isTrue);
        expect(lockService.isPinWeak('9999'), isTrue);
      });

      test('detects weak PIN with sequential digits (ascending)', () {
        expect(lockService.isPinWeak('1234'), isTrue);
        expect(lockService.isPinWeak('2345'), isTrue);
        expect(lockService.isPinWeak('0123'), isTrue);
        expect(lockService.isPinWeak('5678'), isTrue);
      });

      test('detects weak PIN with sequential digits (descending)', () {
        expect(lockService.isPinWeak('4321'), isTrue);
        expect(lockService.isPinWeak('5432'), isTrue);
        expect(lockService.isPinWeak('3210'), isTrue);
        expect(lockService.isPinWeak('9876'), isTrue);
      });

      test('detects common weak patterns', () {
        expect(lockService.isPinWeak('1212'), isTrue);
        expect(lockService.isPinWeak('1122'), isTrue);
      });

      test('strong PIN is not weak', () {
        expect(lockService.isPinWeak('7293'), isFalse);
        expect(lockService.isPinWeak('8516'), isFalse);
        expect(lockService.isPinWeak('3847'), isFalse);
        expect(lockService.isPinWeak('9052'), isFalse);
      });

      test('getPinStrengthLevel returns 0 for repeating digits', () {
        expect(lockService.getPinStrengthLevel('1111'), equals(0));
        expect(lockService.getPinStrengthLevel('0000'), equals(0));
      });

      test('getPinStrengthLevel returns 1 for sequential digits', () {
        expect(lockService.getPinStrengthLevel('1234'), equals(1));
        expect(lockService.getPinStrengthLevel('4321'), equals(1));
      });

      test('getPinStrengthLevel returns >= 2 for strong PIN', () {
        final level = lockService.getPinStrengthLevel('7293');
        expect(level, greaterThanOrEqualTo(2));
      });

      test('getPinStrengthDescription returns Very Weak for repeating', () {
        expect(lockService.getPinStrengthDescription('1111'),
            contains('Very Weak'));
        expect(lockService.getPinStrengthDescription('0000'),
            contains('Very Weak'));
      });

      test('getPinStrengthDescription returns Weak for sequential', () {
        expect(lockService.getPinStrengthDescription('1234'), contains('Weak'));
        expect(lockService.getPinStrengthDescription('4321'), contains('Weak'));
      });
    });

    group('Singleton Pattern', () {
      test('instance returns same object', () {
        final instance1 = AppLockService.instance;
        final instance2 = AppLockService.instance;
        expect(identical(instance1, instance2), isTrue);
      });
    });
  });
}
