abstract class Failure {
  final String message;
  const Failure(this.message);

  @override
  String toString() => message;
}

class AuthFailure extends Failure {
  const AuthFailure(super.message);

  factory AuthFailure.fromCode(String code) {
    switch (code) {
      case 'email-already-in-use':
        return const AuthFailure('This email is already registered.');
      case 'invalid-email':
        return const AuthFailure('The email address is invalid.');
      case 'user-disabled':
        return const AuthFailure('This account has been disabled.');
      case 'user-not-found':
        return const AuthFailure('No account found with this email.');
      case 'wrong-password':
        return const AuthFailure('Incorrect password.');
      case 'weak-password':
        return const AuthFailure('Password is too weak.');
      case 'too-many-requests':
        return const AuthFailure('Too many attempts. Please try again later.');
      case 'operation-not-allowed':
        return const AuthFailure('This sign-in method is not enabled.');
      default:
        return AuthFailure('Authentication failed: $code');
    }
  }
}

class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error occurred.']);
}

class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'No internet connection.']);
}

class CacheFailure extends Failure {
  const CacheFailure([super.message = 'Cache error occurred.']);
}
