import 'package:flutter/material.dart';

buildSnapshot<T>(
    {required Widget childError,
    required Widget childLoading,
    required Widget Function(BuildContext context, AsyncSnapshot<T> snapshot)
        builder}) {
  return (BuildContext context, AsyncSnapshot<T> snapshot) {
    if (snapshot.hasError) {
      return childError;
    }

    if (snapshot.hasData) {
      return builder(context, snapshot);
    }

    return childLoading;
  };
}
