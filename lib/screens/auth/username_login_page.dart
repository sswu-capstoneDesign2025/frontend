import 'package:flutter/material.dart';
import 'package:capstone_story_app/services/auth_service.dart';
import 'package:capstone_story_app/screens/home/home_screen.dart';

import '../root_decider.dart';

class UsernameLoginPage extends StatefulWidget {
  const UsernameLoginPage({Key? key}) : super(key: key);

  @override
  State<UsernameLoginPage> createState() => _UsernameLoginPageState();
}

class _UsernameLoginPageState extends State<UsernameLoginPage> {
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  bool _loading = false;
  bool _obscure = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _usernameFocusNode.addListener(() => setState(() {}));
    _passwordFocusNode.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _usernameFocusNode.dispose();
    _passwordFocusNode.dispose();
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3FFCD),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        title: const Text(
          "로그인",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: MediaQuery.of(context).size.height -
                MediaQuery.of(context).padding.top -
                kToolbarHeight,
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 100),
                const Text("아이디", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                TextField(
                  controller: _usernameController,
                  focusNode: _usernameFocusNode,
                  decoration: InputDecoration(
                    hintText: "아이디를 입력해주세요",
                    hintStyle: TextStyle(color: Colors.grey.shade500),
                    prefixIcon: const Icon(Icons.person_outline, color: Colors.grey),
                    filled: true,
                    fillColor: _usernameFocusNode.hasFocus
                        ? Colors.green.shade100
                        : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green.shade600, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text("비밀번호", style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  focusNode: _passwordFocusNode,
                  obscureText: _obscure,
                  decoration: InputDecoration(
                    hintText: "비밀번호를 입력해주세요",
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey.shade700,
                      ),
                      onPressed: () => setState(() => _obscure = !_obscure),
                    ),
                    filled: true,
                    fillColor: _passwordFocusNode.hasFocus
                        ? Colors.green.shade100
                        : Colors.white,
                    contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.green.shade600, width: 1.5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                const SizedBox(height: 60),
                if (_error != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(_error!, style: const TextStyle(color: Colors.red)),
                  ),
                ElevatedButton(
                  onPressed: _loading ? null : () async {
                    setState(() {
                      _loading = true;
                      _error = null;
                    });
                    try {
                      final token = await AuthService.loginWithUsernamePassword(
                        username: _usernameController.text.trim(),
                        password: _passwordController.text,
                      );
                      await AuthService.loginWithUsernamePassword(
                        username: _usernameController.text.trim(),
                        password: _passwordController.text,
                      );

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const RootDecider()),
                      );
                    } catch (eF) {
                      print("로그인 에러: $eF");
                      setState(() {
                        _error = "로그인에 실패했습니다";
                      });
                    } finally {
                      setState(() {
                        _loading = false;
                      });
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF79C880),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _loading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                      : const Text("로그인", style: TextStyle(fontSize: 16)),
                ),
                const SizedBox(height: 16),
                Center(
                  child: TextButton(
                    onPressed: () {
                      // 회원가입 페이지로 이동
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      "회원가입",
                      style: TextStyle(
                        color: Color(0xFF79C880),
                        decoration: TextDecoration.underline,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
