import 'package:flutter/material.dart';

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
    setState(() {
      isChecking = true;
      showIdCheckMessage = true;
    });

    await Future.delayed(const Duration(seconds: 1)); // API 대체

    setState(() {
      isIdAvailable = true;
      isChecking = false;
    });
  }

  void submitSignUp() {
    // TODO: 회원가입 API 호출
    print("회원가입 정보:");
    print("ID: ${idController.text}");
    print("PW: ${passwordController.text}");
    print("Name: ${nameController.text}");
    print("Phone: ${phoneController.text}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE3FFCD),
      appBar: AppBar(
        backgroundColor: const Color(0xFFE3FFCD),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '회원가입',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 아이디 입력
            const Text("아이디", style: TextStyle(fontWeight: FontWeight.bold)),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: idController,
                    decoration: const InputDecoration(
                      hintText: "아이디를 입력해주세요",
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(16)),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: isChecking ? null : checkIdAvailability,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFC8F3D1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text("확인", style: TextStyle(color: Colors.black)),
                ),
              ],
            ),
            if (showIdCheckMessage)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  isIdAvailable ? "사용가능한 아이디입니다" : "이미 사용중인 아이디입니다",
                  style: TextStyle(color: isIdAvailable ? Colors.green : Colors.red),
                ),
              ),
            const SizedBox(height: 20),

            // 비밀번호
            const Text("비밀번호", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "비밀번호를 입력해주세요",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 이름
            const Text("이름", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                hintText: "사용자님의 이름을 입력해주세요",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // 휴대폰번호
            const Text("휴대폰번호", style: TextStyle(fontWeight: FontWeight.bold)),
            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                hintText: "휴대폰 번호를 입력해주세요",
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: 30),

            // 회원가입 버튼
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: submitSignUp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF78CF97),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text("회원가입", style: TextStyle(fontSize: 18)),
              ),
            ),
            const SizedBox(height: 20),

            // 로그인으로 이동
            Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: const Text(
                  "로그인",
                  style: TextStyle(
                    decoration: TextDecoration.underline,
                    color: Color(0xFF3C7D52),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
