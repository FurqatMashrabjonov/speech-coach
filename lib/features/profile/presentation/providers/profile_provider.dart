import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_coach/features/auth/domain/user_entity.dart';
import 'package:speech_coach/features/auth/presentation/providers/auth_provider.dart';

final profileProvider = FutureProvider<UserEntity?>((ref) async {
  final authRepo = ref.read(authRepositoryProvider);
  final currentUser = authRepo.currentUser;
  if (currentUser == null) return null;

  // Try Firestore profile first
  final profile = await authRepo.getUserProfile(currentUser.uid);
  if (profile != null) return profile;

  // Fallback: build profile from Firebase Auth data (works without Firestore)
  return UserEntity(
    uid: currentUser.uid,
    email: currentUser.email ?? '',
    displayName: currentUser.displayName,
    photoUrl: currentUser.photoURL,
    createdAt: currentUser.metadata.creationTime ?? DateTime.now(),
  );
});
