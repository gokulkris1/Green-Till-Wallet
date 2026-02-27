import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:greentill/bloc/main_bloc.dart';
import 'package:greentill/main.dart';
import 'package:greentill/ui/screens/signup/signup_screen.dart';
import 'package:greentill/utils/strings.dart';
import 'package:greentill/utils/shared_pref_helper.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPrefHelper.createInstance();
    await SharedPrefHelper.instance.clear();
  });

  testWidgets('Sign up screen loads', (tester) async {
    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider<MainBloc>(
            create: (context) => MainBloc(splashDelay: Duration.zero),
          ),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
    expect(find.byType(SignUpScreen), findsOneWidget);
    expect(find.text(Signup), findsWidgets);
  });
}
