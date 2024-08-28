import 'dart:convert';

import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:tdd/core/error/exceptions.dart';
import 'package:tdd/features/number_trivia/data/datasources/number_trivia_remote_data_source.dart';
import 'package:tdd/features/number_trivia/data/models/number_trivia_model.dart';

import '../../../../fixtures/fixture_reader.dart';
import 'number_trivia_remote_data_source_test.mocks.dart';

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  late NumberTriviaRemoteDataSourceImpl dataSource;
  late MockClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockClient();
    dataSource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHttpClientSuccess200(int number) {
    when(mockHttpClient.get(
      Uri.parse('http://numbersapi.com/$number'),
      headers: anyNamed('headers'),
    )).thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHttpClientFailureRandom() {
    when(mockHttpClient.get(
      Uri.parse('http://numbersapi.com/random'),
      headers: anyNamed('headers'),
    )).thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  void setUpMockHttpClientSuccessRandom() {
    when(mockHttpClient.get(
      Uri.parse('http://numbersapi.com/random'),
      headers: anyNamed('headers'),
    )).thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      'should perform a GET request on a URL with number being the endpoint and with application/json header',
      () async {
        // arrange
        setUpMockHttpClientSuccess200(tNumber);
        // act
        await dataSource.getConcreteNumberTrivia(tNumber);
        // assert
        verify(mockHttpClient.get(
          Uri.parse('http://numbersapi.com/$tNumber'),
          headers: {
            'Content-Type': 'application/json',
          },
        ));
      },
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        // arrange
        setUpMockHttpClientSuccess200(tNumber);
        // act
        final result = await dataSource.getConcreteNumberTrivia(tNumber);
        // assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        // arrange
       when(mockHttpClient.get(
          Uri.parse('http://numbersapi.com/$tNumber'),
          headers: anyNamed('headers'),
        )).thenAnswer((_) async => http.Response('Something went wrong', 404));
        // act
        call() async => await dataSource.getConcreteNumberTrivia(tNumber);
        // assert
        expect(call, throwsA(isA<ServerException>()));
      },
    );
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test(
      'should perform a GET request on a URL with number being the endpoint and with application/json header',
      () async {
        // arrange
        setUpMockHttpClientSuccessRandom();
        // act
        await dataSource.getRandomNumberTrivia();
        // assert
        verify(mockHttpClient.get(
          Uri.parse('http://numbersapi.com/random'),
          headers: {
            'Content-Type': 'application/json',
          },
        ));
      },
    );

    test(
      'should return NumberTrivia when the response code is 200 (success)',
      () async {
        // arrange
        setUpMockHttpClientSuccessRandom();
        // act
        final result = await dataSource.getRandomNumberTrivia();
        // assert
        expect(result, equals(tNumberTriviaModel));
      },
    );

    test(
      'should throw a ServerException when the response code is 404 or other',
      () async {
        // arrange
        setUpMockHttpClientFailureRandom();
        // act
        final call =  dataSource.getRandomNumberTrivia;
        // assert
        expect(() async => await call(), throwsA(isA<ServerException>()));
      },
    );
  });
}
