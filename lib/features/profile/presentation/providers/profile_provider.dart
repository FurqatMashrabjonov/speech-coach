import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/features/auth/domain/user_entity.dart';
import 'package:speech_coach/features/auth/presentation/providers/auth_provider.dart';

final profileProvider = FutureProvider<UserEntity?>((ref) async {
  final authRepo = ref.read(authRepositoryProvider);
  final currentUser = authRepo.currentUser;
  if (currentUser == null) return null;
  return authRepo.getUserProfile(currentUser.uid);
});
