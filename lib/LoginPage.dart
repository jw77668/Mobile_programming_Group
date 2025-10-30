class LoginPage extends StatelessWidget {
  final TextEditingController emailCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('앱 이름', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 40),
            Text('계정 만들기\n이 앱에 가입하려면 이메일을 입력하세요',
                textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
            const SizedBox(height: 12),
            TextField(
              controller: emailCtrl,
              decoration: InputDecoration(
                hintText: 'email@domain.com',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => HomePage()));
              },
              child: Text('계속'),
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 45)),
            ),
            const SizedBox(height: 12),
            Text('또는', style: TextStyle(fontSize: 12)),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.g_mobiledata),
              label: Text('Google 계정으로 계속하기'),
              onPressed: () {},
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 45)),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              icon: Icon(Icons.apple),
              label: Text('Apple 계정으로 계속하기'),
              onPressed: () {},
              style: ElevatedButton.styleFrom(minimumSize: Size(double.infinity, 45)),
            ),
          ],
        ),
      ),
    );
  }
}