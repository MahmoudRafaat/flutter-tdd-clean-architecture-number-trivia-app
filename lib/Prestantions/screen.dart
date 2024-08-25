
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:training/Domain/bloc/news_cubit.dart';
import 'package:training/Domain/bloc/news_state.dart';

class Showproducts extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => NewsCubit()..getAllNews(),
      child: BlocConsumer<NewsCubit, NewsState>(
        listener: (context, state) {},
        builder: (context, state) {
          final newsCubit = context.read<NewsCubit>();

          if (state is NewsLoaded) {
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  "Products",
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.blue,
              ),
              backgroundColor: Colors.white,
              body: ListView.builder(
                itemCount: newsCubit.news.length,
                itemBuilder: (context, index) {
                  final product = newsCubit.news[index];
                  return Card(
                    color: Colors.white,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(product.title.toString())
                        ),
                        Text(
                          product.body.toString(),
                          style:const TextStyle(
                            fontSize: 20,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                      ],
                    ),
                  );
                },
              ),
            );
          } else if (state is NewsError) {
            return Center(
              child: Text(state.errorMessage),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}