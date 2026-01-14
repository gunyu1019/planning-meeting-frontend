class AgentMessage {
  final String id;
  final String role;

  /// This Unique-ID uses to keep session.
  final String threadId;
  final String tenantId;

  final DateTime created;

  final String content;

  AgentMessage(
    this.id,
    this.role,
    this.threadId,
    this.tenantId,
    this.created,
    this.content,
  );
}
