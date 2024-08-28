import 'package:dartz/dartz.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tdd/core/error/failures.dart';
import 'package:tdd/core/usecases/usecase.dart';
import 'package:tdd/core/util/input_converter.dart';
import 'package:tdd/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:tdd/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:tdd/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:tdd/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:tdd/features/number_trivia/presentation/bloc/number_trivia_event.dart';
import 'package:tdd/features/number_trivia/presentation/bloc/number_trivia_state.dart';

import 'number_trivia_bloc_test.mocks.dart';

@GenerateMocks([
  GetConcreteNumberTrivia,
  GetRandomNumberTrivia,
  InputConverter,
])
void main() {
  late NumberTriviaBloc bloc;
  late MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  late MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  late MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
      getConcreteNumberTrivia: mockGetConcreteNumberTrivia,
      getRandomNumberTrivia: mockGetRandomNumberTrivia,
      inputConverter: mockInputConverter,
    );
  });

  test('initialState should be Empty', () {
    // assert
    expect(bloc.state, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    const tNumberString = '1';
    const tNumberParsed = 1;
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    void setUpMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInteger(any))
            .thenReturn(const Right(tNumberParsed));

    test(
        'should call the InputConverter to validate and convert the string to an unsigned integer',
        () async* {
      // arrange
      setUpMockInputConverterSuccess();

      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));

      await untilCalled(mockInputConverter.stringToUnsignedInteger(any));

      // assert
      verify(mockInputConverter.stringToUnsignedInteger(tNumberString));

      final expected = [Empty(), Loading(), Loaded(trivia: tNumberTrivia)];
      expectLater(
        bloc.stream.asBroadcastStream(),
        emitsInOrder(expected),
      );
    });

    test('should emit [Error] when input is invalid', () async* {
      when(mockInputConverter.stringToUnsignedInteger(any))
          .thenReturn(Left(InvalidInputFailure()));

      final expected = [Empty(), Error(message: invalidInputFailure)];
      expectLater(bloc.stream.asBroadcastStream(), emitsInOrder(expected));

      bloc.add(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should get data from the concrete use case', () async* {
      // arrange
      setUpMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => const Right(tNumberTrivia));

      // act
      bloc.add(GetTriviaForConcreteNumber(tNumberString));

      // assert
      await untilCalled(mockGetConcreteNumberTrivia(any));
      verify(mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));

      final expected = [
        Empty(),
        Loading(),
        Loaded(trivia: tNumberTrivia),
      ];
      expectLater(
        bloc.stream,
        emitsInOrder(expected),
      );
    });

    test(
      'should emit [Loading, Loaded] when data is successfully retrieved',
      () async* {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));

        // act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));

        // assert
        await untilCalled(mockGetConcreteNumberTrivia(any));
        verify(
            mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));

        final expected = [
          Empty(),
          Loading(),
          Loaded(trivia: tNumberTrivia),
        ];
        expectLater(
          bloc.stream.asBroadcastStream(),
          emitsInOrder(expected),
        );
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
      () async* {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));

        // act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));

        // assert
        await untilCalled(mockGetConcreteNumberTrivia(any));
        verify(
            mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));

        final expected = [
          Empty(),
          Loading(),
          Error(message: serverFailureMessage),
        ];
        expectLater(
          bloc.stream.asBroadcastStream(),
          emitsInOrder(expected),
        );
      },
    );

    test(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      () async* {
        // arrange
        setUpMockInputConverterSuccess();
        when(mockGetConcreteNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));

        // act
        bloc.add(GetTriviaForConcreteNumber(tNumberString));

        // assert
        await untilCalled(mockGetConcreteNumberTrivia(any));
        verify(
            mockGetConcreteNumberTrivia(const Params(number: tNumberParsed)));

        final expected = [
          Empty(),
          Loading(),
          Error(message: cacheFailureMessage),
        ];
        expectLater(
          bloc.stream.asBroadcastStream(),
          emitsInOrder(expected),
        );
      },
    );
  });

// For Random test

  group('GetTriviaForRandomNumber', () {
    const tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    test(
      'should get data from the random use case',
      () async* {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));

        // act
        bloc.add(GetTriviaForRandomNumber());

        // assert
        await untilCalled(mockGetRandomNumberTrivia(any));
        verify(mockGetRandomNumberTrivia(NoParams()));
      },
    );

    test(
      'should emit [Loading, Loaded] when data is successfully retrieved',
      () async* {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => const Right(tNumberTrivia));

        // act
        bloc.add(GetTriviaForRandomNumber());

        // assert
        await untilCalled(mockGetRandomNumberTrivia(any));
        verify(mockGetRandomNumberTrivia(NoParams()));

        final expected = [
          Empty(),
          Loading(),
          Loaded(trivia: tNumberTrivia),
        ];
        expectLater(
          bloc.stream.asBroadcastStream(),
          emitsInOrder(expected),
        );
      },
    );

    test(
      'should emit [Loading, Error] when getting data fails',
      () async* {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(ServerFailure()));

        // act
        bloc.add(GetTriviaForRandomNumber());

        // assert
        await untilCalled(mockGetRandomNumberTrivia(any));
        verify(mockGetRandomNumberTrivia(NoParams()));

        final expected = [
          Empty(),
          Loading(),
          Error(message: serverFailureMessage),
        ];
        expectLater(
          bloc.stream.asBroadcastStream(),
          emitsInOrder(expected),
        );
      },
    );

    test(
      'should emit [Loading, Error] with a proper message for the error when getting data fails',
      () async* {
        // arrange
        when(mockGetRandomNumberTrivia(any))
            .thenAnswer((_) async => Left(CacheFailure()));

        // act
        bloc.add(GetTriviaForRandomNumber());

        // assert
        await untilCalled(mockGetRandomNumberTrivia(any));
        verify(mockGetRandomNumberTrivia(NoParams()));

        final expected = [
          Empty(),
          Loading(),
          Error(message: cacheFailureMessage),
        ];
        expectLater(
          bloc.stream.asBroadcastStream(),
          emitsInOrder(expected),
        );
      },
    );
  });
}
