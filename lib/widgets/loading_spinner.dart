import 'package:flutter/material.dart';
import 'package:laroona_flutter_lib/resources/dimensions.dart';

class LoadingSpinner extends StatelessWidget {
  const LoadingSpinner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key("loading"),
      padding: const EdgeInsets.all(paddingSizeSmall),
      color: Colors.transparent,
      child: const Center(
        child: SizedBox(
          width: loadingSize,
          height: loadingSize,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }
}
