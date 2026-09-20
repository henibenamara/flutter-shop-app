import '../../domain/entities/session.dart';
import '../../domain/entities/user.dart';

class SessionModel extends Session {
  const SessionModel({required super.user, required super.accessToken});

  factory SessionModel.fromEntity(Session session) {
    return SessionModel(user: session.user, accessToken: session.accessToken);
  }

  /// Reads the login response and what [toJson] stored: they share one shape.
  factory SessionModel.fromJson(Map<String, dynamic> json) {
    return SessionModel(
      user: User(
        id: json['id'] as int,
        username: json['username'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        email: json['email'] as String,
        imageUrl: json['image'] as String?,
      ),
      accessToken: (json['accessToken'] ?? json['token']) as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': user.id,
        'username': user.username,
        'firstName': user.firstName,
        'lastName': user.lastName,
        'email': user.email,
        'image': user.imageUrl,
        'accessToken': accessToken,
      };
}
