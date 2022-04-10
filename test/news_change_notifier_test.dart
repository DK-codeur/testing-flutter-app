import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_testing_tutorial/article.dart';
import 'package:flutter_testing_tutorial/news_change_notifier.dart';
import 'package:flutter_testing_tutorial/news_service.dart';
import 'package:mocktail/mocktail.dart';

class MockNewsService extends Mock implements NewsService {}

void main() {
  late NewsChangeNotifier sut; //sut: systeme under test
  late MockNewsService mockNewsService;

  setUp(() { //config methode
    mockNewsService = MockNewsService();
    sut = NewsChangeNotifier(mockNewsService);
  });

  test(
    "initial value are correct", 
    () {
      expect(sut.articles, []);
      expect(sut.isLoading, false);

    }
  );

  group("getArticles:",  () {

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

    test(
      "gets articles using the NewsService",
      () async {
        
        arrangeNewsServiceReturns3Articles(); //aaaTest : arrange
        await sut.getArticles(); //act
        verify(() => mockNewsService.getArticles()).called(1); //assert
      },
    );

    test(
      "indicates loading of data, sets articles to the ones from the service, indicates that data is not being loaded anymore",
      () async {
        arrangeNewsServiceReturns3Articles();
        final future = sut.getArticles();
        expect(sut.isLoading, true);
        await future;
        expect(sut.articles, articlesFromService);
        expect(sut.isLoading, false);
      },
    );
  });


  
}