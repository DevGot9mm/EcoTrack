import 'package:flutter/material.dart';

import '../icons.dart';
import '../store.dart';
import '../theme.dart';
import '../widgets/common.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  static final RegExp _emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _pass = TextEditingController();

  bool _badName = false;
  bool _badEmail = false;
  bool _badPass = false;
  bool _alertOn = false;
  bool _loading = false;
  String _alertText = '';

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _clearErrors() {
    _badName = false;
    _badEmail = false;
    _badPass = false;
    _alertOn = false;
  }

  void _submit(EcoStore store) {
    final bool isLogin = store.authMode == 'login';
    final bool nameOk = isLogin || _name.text.trim().length >= 2;
    final bool emailOk = _emailRe.hasMatch(_email.text.trim());
    final bool passOk = _pass.text.length >= 8;

    final List<String> msgs = <String>[];
    if (!nameOk) msgs.add('name');
    if (!emailOk) msgs.add('email');
    if (!passOk) msgs.add('password');

    setState(() {
      _badName = !nameOk;
      _badEmail = !emailOk;
      _badPass = !passOk;
      if (msgs.isNotEmpty) {
        _alertOn = true;
        _alertText = msgs.length > 1
            ? 'Please fix ${msgs.length} fields: ${msgs.join(', ')}.'
            : 'Please check the highlighted field.';
      } else {
        _alertOn = false;
        _loading = true;
      }
    });

    if (msgs.isNotEmpty) return;

    Future<void>.delayed(const Duration(milliseconds: 900), () {
      if (!mounted) return;
      store.setPlayerName(_name.text);
      setState(() => _loading = false);
      store.toast('Welcome to EcoTrack, ${store.playerName}!', kIcons['leaf']);
      store.go('home');
    });
  }

  InputBorder _border(bool invalid, {bool focused = false}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(Eco.rBtn),
      borderSide: BorderSide(
        color: invalid ? Eco.danger : (focused ? Eco.forest : Eco.lineStrong),
        width: 1.5,
      ),
    );
  }

  Widget _field({
    required String label,
    required TextEditingController ctrl,
    required String hint,
    required bool invalid,
    required String error,
    String? helper,
    bool obscure = false,
    TextInputType? keyboard,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Text.rich(
              TextSpan(
                children: <InlineSpan>[
                  TextSpan(
                    text: label,
                    style: F.b(13.5, wght: 800, color: Eco.ink2),
                  ),
                  TextSpan(
                    text: ' *',
                    style: F.b(13.5, wght: 800, color: Eco.danger),
                  ),
                ],
              ),
            ),
          ),
          TextField(
            controller: ctrl,
            obscureText: obscure,
            keyboardType: keyboard,
            style: F.b(16),
            cursorColor: Eco.forest,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: Eco.surface,
              hintText: hint,
              hintStyle: F.b(16, color: const Color(0xFF9AA79B)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 17,
              ),
              border: _border(invalid),
              enabledBorder: _border(invalid),
              focusedBorder: _border(invalid, focused: true),
              errorBorder: _border(true),
              focusedErrorBorder: _border(true, focused: true),
            ),
          ),
          if (invalid)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: <Widget>[
                  const EcoIcon('info', size: 15, color: Eco.danger),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      error,
                      style: F.b(13, wght: 700, color: Eco.danger),
                    ),
                  ),
                ],
              ),
            ),
          if (helper != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(helper, style: F.b(12.5, color: Eco.muted)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final bool isLogin = store.authMode == 'login';

    final Widget alert = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Eco.dangerTint,
        borderRadius: BorderRadius.circular(Eco.rSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.only(top: 1),
            child: EcoIcon('info', size: 17, color: Color(0xFF7D2C1C)),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _alertText,
              style: F.b(
                13.5,
                wght: 700,
                height: 1.45,
                color: const Color(0xFF7D2C1C),
              ),
            ),
          ),
        ],
      ),
    );

    return Scaffold(
      backgroundColor: Eco.ground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: EcoIconButton(
                  'chevronL',
                  plain: true,
                  onPressed: () => store.go('welcome'),
                ),
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Row(
                      children: <Widget>[
                        MascotCrop('face-happy', size: 64, radius: 32),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(isLogin ? 'Welcome back' : 'Join EcoTrack',
                                  style: F.h1),
                              const SizedBox(height: 4),
                              Text(
                                isLogin
                                    ? 'Pick up where you left off.'
                                    : 'Your first activity takes about 20 seconds.',
                                style: F.b(14, color: Eco.muted),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    EcoSegmented(
                      items: const <String>['Log in', 'Sign up'],
                      index: isLogin ? 0 : 1,
                      onChanged: (int i) {
                        setState(_clearErrors);
                        store.setAuthMode(i == 0 ? 'login' : 'signup');
                      },
                    ),
                    const SizedBox(height: 22),
                    if (_alertOn) alert,
                    if (!isLogin)
                      _field(
                        label: 'Your name',
                        ctrl: _name,
                        hint: 'Aya Rahman',
                        invalid: _badName,
                        error: 'Enter the name you want shown on your profile.',
                        keyboard: TextInputType.name,
                      ),
                    _field(
                      label: 'Email',
                      ctrl: _email,
                      hint: 'you@example.com',
                      invalid: _badEmail,
                      error:
                          'That email does not look right — check for a missing @ or dot.',
                      keyboard: TextInputType.emailAddress,
                    ),
                    _field(
                      label: 'Password',
                      ctrl: _pass,
                      hint: 'At least 8 characters',
                      invalid: _badPass,
                      obscure: true,
                      error: isLogin
                          ? 'Enter your password to continue.'
                          : 'Use at least 8 characters so your account stays safe.',
                      helper: isLogin
                          ? null
                          : 'We only use this to sign you back in — nothing is shared.',
                    ),
                    const SizedBox(height: 6),
                    EcoButton(
                      label: isLogin ? 'Log in' : 'Create my account',
                      block: true,
                      loading: _loading,
                      loadingLabel: 'Signing you in…',
                      onPressed: () => _submit(store),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: <Widget>[
                        const Expanded(
                          child: Divider(color: Eco.line, height: 1),
                        ),
                        const SizedBox(width: 12),
                        Text('or', style: F.caption),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Divider(color: Eco.line, height: 1),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    EcoButton(
                      label: 'Continue with Google account',
                      leading: 'google',
                      tone: EcoButtonTone.ghost,
                      block: true,
                      onPressed: () => store.go('home'),
                    ),
                    const SizedBox(height: 10),
                    EcoButton(
                      label: 'Continue as guest',
                      leading: 'user',
                      tone: EcoButtonTone.ghost,
                      block: true,
                      onPressed: () {
                        store.setPlayerName('Guest');
                        store.go('home');
                      },
                    ),
                    const SizedBox(height: 18),
                    Text(
                      'Prototype only — no account is created and nothing leaves this device.',
                      textAlign: TextAlign.center,
                      style: F.caption,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
