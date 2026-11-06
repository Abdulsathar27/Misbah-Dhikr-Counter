import 'package:equatable/equatable.dart';

/// A recoverable error surfaced to the presentation layer.
sealed class Failure extends Equatable {
  const Failure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

final class PersistenceFailure extends Failure {
  const PersistenceFailure([super.message = 'Your settings could not be saved.']);
}
