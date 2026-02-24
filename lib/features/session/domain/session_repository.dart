import 'package:speech_coach/features/session/domain/session_entity.dart';

abstract class SessionRepository {
  Future<void> saveSession(SessionEntity session);
  Future<SessionEntity?> getSession(String sessionId);
  Future<List<SessionEntity>> getUserSessions(String userId);
  Future<String> uploadAudio(String userId, String sessionId, String filePath);
}
