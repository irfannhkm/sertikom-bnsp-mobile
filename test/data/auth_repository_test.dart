import 'package:agenda_nusantara/data/auth_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AuthRepository repo;

  const defaultUser = 'Irfan';
  const defaultPass = 'Password123';

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    repo = AuthRepository(
      defaultUsername: defaultUser,
      defaultPassword: defaultPass,
    );
    await repo.seedDefaultUserIfMissing();
  });

  test('seed creates default user when missing', () async {
    expect(await repo.getUsername(), defaultUser);
    expect(await repo.verify(defaultUser, defaultPass), true);
  });

  test('verify wrong password returns false', () async {
    expect(await repo.verify(defaultUser, 'salah'), false);
  });

  test('verify wrong username returns false', () async {
    expect(await repo.verify('admin', defaultPass), false);
  });

  test('changePassword: success when old correct', () async {
    expect(await repo.changePassword(defaultPass, 'baru1234'), true);
    expect(await repo.verify(defaultUser, 'baru1234'), true);
    expect(await repo.verify(defaultUser, defaultPass), false);
  });

  test('changePassword: fail when old wrong', () async {
    expect(await repo.changePassword('salah', 'baru1234'), false);
    expect(await repo.verify(defaultUser, defaultPass), true);
  });

  test('session: setLoggedIn / isLoggedIn / logout', () async {
    expect(await repo.isLoggedIn(), false);
    await repo.setLoggedIn(true);
    expect(await repo.isLoggedIn(), true);
    await repo.logout();
    expect(await repo.isLoggedIn(), false);
  });

  test('seed does not overwrite existing user', () async {
    await repo.changePassword(defaultPass, 'baru1234');
    final repo2 = AuthRepository(
      defaultUsername: defaultUser,
      defaultPassword: defaultPass,
    );
    await repo2.seedDefaultUserIfMissing();
    expect(await repo2.verify(defaultUser, 'baru1234'), true);
  });
}
