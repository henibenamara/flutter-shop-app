import 'package:equatable/equatable.dart';

import 'user.dart';

/// A signed-in user together with the token to call the API with.
class Session extends Equatable {
  const Session({required this.user, required this.accessToken});

  final User user;
  final String accessToken;

  @override
  List<Object?> get props => [user, accessToken];
}
