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

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _emailFocus = FocusNode();
  final FocusNode _passFocus = FocusNode();

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
    _nameFocus.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
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

  InputBorder _border(bool invalid, {bool focused = false, required ColorScheme cs}) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(Eco.rBtn),
      borderSide: BorderSide(
        color: invalid ? cs.danger : (focused ? cs.leaf : cs.lineStrong),
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
    TextInputAction? textInputAction,
    FocusNode? focusNode,
    void Function()? onSubmitted,
    required ColorScheme cs,
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
                    style: F.b(13.5, wght: 800, color: cs.ink2),
                  ),
                  TextSpan(
                    text: ' *',
                    style: F.b(13.5, wght: 800, color: cs.danger),
                  ),
                ],
              ),
            ),
          ),
          TextField(
            controller: ctrl,
            obscureText: obscure,
            keyboardType: keyboard,
            textInputAction: textInputAction,
            focusNode: focusNode,
            onSubmitted: (_) => onSubmitted?.call(),
            style: F.b(16),
            cursorColor: cs.leaf,
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: cs.surface,
              hintText: hint,
              hintStyle: F.b(16, color: const Color(0xFF9AA79B)),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 17,
              ),
              border: _border(invalid, cs: cs),
              enabledBorder: _border(invalid, cs: cs),
              focusedBorder: _border(invalid, focused: true, cs: cs),
              errorBorder: _border(true, cs: cs),
              focusedErrorBorder: _border(true, focused: true, cs: cs),
            ),
          ),
          if (invalid)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Row(
                children: <Widget>[
                  EcoIcon('info', size: 15, color: cs.danger),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      error,
                      style: F.b(13, wght: 700, color: cs.danger),
                    ),
                  ),
                ],
              ),
            ),
          if (helper != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(helper, style: F.b(12.5, color: cs.muted)),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final EcoStore store = EcoScope.of(context);
    final cs = Theme.of(context).colorScheme;
    final bool isLogin = store.authMode == 'login';

    final Widget alert = Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: cs.dangerTint,
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
      backgroundColor: cs.ground,
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
                                style: F.b(14, color: cs.muted),
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
                        textInputAction: TextInputAction.next,
                        onSubmitted: () => _emailFocus.requestFocus(),
                        cs: cs,
                      ),
                    _field(
                      label: 'Email',
                      ctrl: _email,
                      hint: 'you@example.com',
                      invalid: _badEmail,
                      error:
                          'That email does not look right — check for a missing @ or dot.',
                      keyboard: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      focusNode: _emailFocus,
                      onSubmitted: () => _passFocus.requestFocus(),
                      cs: cs,
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
                      textInputAction: TextInputAction.done,
                      focusNode: _passFocus,
                      onSubmitted: () => _submit(store),
                      cs: cs,
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
                        Expanded(
                          child: Divider(color: cs.outline, height: 1),
                        ),
                        const SizedBox(width: 12),
                        Text('or', style: F.b(13, height: 1.45, color: cs.muted)),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Divider(color: cs.outline, height: 1),
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
                      style: F.b(13, height: 1.45, color: cs.muted),
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
