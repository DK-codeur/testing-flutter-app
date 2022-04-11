// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_page.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';


class MockNewsService extends Mock implements NewsService {}

//t_s
//widget test
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

  void arrangeNewsServiceReturns3ArticlesAfter2secondWait() {
    when(() => mockNewsService.getArticles()).thenAnswer(
      (_) async {
        await Future.delayed(const Duration(seconds: 2));
        return articlesFromService;
      }
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
    "title is displayed",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();
      await tester.pumpWidget(createWidgetUnderTest()); //pump
      expect(find.text("News"), findsOneWidget);
    },
  );

  testWidgets(
    "loading indicator is displayed while waiting for articles",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3ArticlesAfter2secondWait();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump(const Duration(milliseconds: 500));

      // expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byKey(Key("progress-indicator")), findsOneWidget);

      tester.pumpAndSettle(); //attend qu'il ny ait plus d'animation: le loader dans notre cas
    },
  );


  testWidgets(
    "articles are displayed",
    (WidgetTester tester) async {
      arrangeNewsServiceReturns3Articles();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      for(final article in articlesFromService) {
        expect(find.text(article.title), findsOneWidget);
        expect(find.text(article.content), findsOneWidget);
      }
    },
  );
}
