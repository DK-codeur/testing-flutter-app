import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/article_page.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_page.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';


class MockNewsService extends Mock implements NewsService {}

//itest: test on device(real/virtual): action clic...
void main() {
  late MockNewsService mockNewsService;

  setUp(() { //config methode
    mockNewsService = MockNewsService();
  });

  final articlesFromService = [
    Article(title: "test 1", content: "test 1 content"),
    Article(title: "test 2", content: "test 2 content"),
    Article(title: "test 3", content: "test 3 content"),
  ];

  void arrangeNewsServiceReturns3Articles() {
    when(() => mockNewsService.getArticles()).thenAnswer(
      (_) async => articlesFromService
    );
  }

  Widget createWidgetUnderTest() { //pour que l'app soit bien initialiser avec le provider (consumer)
    return MaterialApp(
      title: 'News App',
      home: ChangeNotifierProvider(
        create: (_) => NewsChangeNotifier(mockNewsService),
        child: NewsPage(),
      ),
    );
  }

  testWidgets(
    "tapping on the first article excerpt opens the article page where the full article content is displayed ",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      await tester.tap(find.text("test 1 content"));

      await tester.pumpAndSettle(); //attend que l'animation de navigation finisse

      //une fois la navigation terminer 
      expect(find.byType(NewsPage), findsNothing); //on s'assure que nous ne somme plus sur NewsPage
      expect(find.byType(ArticlePage), findsOneWidget); //mais plutot sur la page ArticlePage

      expect(find.text("test 1"), findsOneWidget);
      expect(find.text("test 1 content"), findsOneWidget);
    },
  );
}