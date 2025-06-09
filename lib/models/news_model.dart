class News {
  final String? url; //  nullable 처리
  final String title;
  final String content;

  News({
    this.url,
    required this.title,
    required this.content,
  });
}
