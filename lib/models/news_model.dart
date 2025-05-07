class News {
  final String title;
  final String content;

  News({required this.title, required this.content});
}

final newsList = [
  News(title: "정부, 기준금리 동결", content: "한국은행이 이자율을 그대로 두기로 했대요."),
  News(title: "비 오는 날, 교통사고 증가", content: "비 오면 도로가 미끄러워져서 사고가 많아져요."),
  // ...
];
