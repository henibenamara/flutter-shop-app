import 'package:equatable/equatable.dart';

import '../../domain/entities/session.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  const AuthState({
    this.status = AuthStatus.unknown,
    this.session,
    this.isSubmitting = false,
    this.errorMessage,
  });

  final AuthStatus status;
  final Session? session;
  final bool isSubmitting;
  final String? errorMessage;

  @override
  List<Object?> get props => [status, session, isSubmitting, errorMessage];
}
