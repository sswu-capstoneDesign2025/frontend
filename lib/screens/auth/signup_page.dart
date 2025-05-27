// signup_page.dart

import 'package:flutter/material.dart';
import 'package:capstone_story_app/services/auth_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({Key? key}) : super(key: key);

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final idController = TextEditingController();
  final passwordController = TextEditingController();
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  bool isChecking = false;
  bool isIdAvailable = false;
  bool showIdCheckMessage = false;

  @override
  void dispose() {
    idController.dispose();
    passwordController.dispose();
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> checkIdAvailability() async {
    final username = idController.text.trim();

    if (username.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("아이디를 입력해주세요.")),
      );
      return;
    }

    setState(() {
      isChecking = true;
      showIdCheckMessage = true;
    });

    try {
      final available = await AuthService.isUsernameAvailable(username);

      setState(() {
        isIdAvailable = available;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("중복 확인 실패: $e")),
      );
      setState(() {
        isIdAvailable = false;
      });
    } finally {
      setState(() {
        isChecking = false;
      });
    }
  }


  void submitSignUp() async {
    final username = idController.text.trim();
    final password = passwordController.text.trim();
    final name = nameController.text.trim();
    final phone = phoneController.text.trim();

    if (username.isEmpty || password.isEmpty || name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("모든 정보를 입력해주세요.")),
      );
      return;
    }

    final result = await AuthService.signup(
      username: username,
      password: password,
      name: name,
      phoneNumber: phone,
    );

    if (result['success']) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("회원가입이 완료되었습니다!")),
      );
      Navigator.pop(context); // 로그인 화면으로 이동
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("회원가입 실패: ${result['error']}")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3FFCD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3FFCD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black, size: 35),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(
            color: Colors.black,
            fontSize: 25,
            fontFamily: 'HakgyoansimGeurimilgi',
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(28),
          child: DefaultTextStyle(
            style: const TextStyle(fontFamily: 'HakgyoansimGeurimilgi', fontSize: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 아이디 입력
                const Text("아이디", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: idController,
                        decoration: const InputDecoration(
                          hintText: "아이디를 입력해주세요",
                          hintStyle: TextStyle(fontFamily: 'HakgyoansimGeurimilgi', fontSize: 18),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(16)),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 90,  // 원하는 가로 길이
                      height: 58,  // 원하는 세로 길이
                      child: ElevatedButton(
                        onPressed: isChecking ? null : checkIdAvailability,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFC8F3D1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        child: const Text(
                          "확인",
                          style: TextStyle(
                            color: Colors.black,
                            fontFamily: 'HakgyoansimGeurimilgi',
                            fontSize: 20,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 7),
                SizedBox(
                  height: 28,
                  child: showIdCheckMessage
                      ? Text(
                    isIdAvailable ? "사용가능한 아이디입니다" : "이미 사용중인 아이디입니다",
                    style: TextStyle(color: isIdAvailable ? Colors.green : Colors.red, fontSize: 18),
                  )
                      : const SizedBox(),
                ),
                const SizedBox(height: 5),

                // 비밀번호
                const Text("비밀번호", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: passwordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    hintText: "비밀번호를 입력해주세요",
                    hintStyle: TextStyle(fontFamily: 'HakgyoansimGeurimilgi', fontSize: 18),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 25),

                // 이름
                const Text("이름", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    hintText: "사용자님의 이름을 입력해주세요",
                    hintStyle: TextStyle(fontFamily: 'HakgyoansimGeurimilgi', fontSize: 18),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 25),

                // 휴대폰번호
                const Text("휴대폰번호", style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    hintText: "휴대폰 번호를 입력해주세요",
                    hintStyle: TextStyle(fontFamily: 'HakgyoansimGeurimilgi', fontSize: 18),
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(16)),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                  ),
                ),
                const SizedBox(height: 50),

                // 회원가입 버튼
                SizedBox(
                  width: double.infinity,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: submitSignUp,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF78CF97),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text("회원가입", style: TextStyle(fontFamily: 'HakgyoansimGeurimilgi', fontSize: 24, fontWeight: FontWeight.bold)),
                  ),
                ),
                const SizedBox(height: 20),

                // 로그인으로 이동
                Center(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Text(
                      "로그인",
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        color: Color(0xFF3C7D52),
                        fontSize: 22,
                        fontFamily: 'HakgyoansimGeurimilgi',
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