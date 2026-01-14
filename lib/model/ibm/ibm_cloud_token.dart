
class IBMAuthentic {
  final String accessToken;
  final String refreshToken;
  final int imsUserId;
  final String tokenType;
  final int expiresIn;
  final DateTime expiration;
  final List<String> scope;

  IBMAuthentic._(this.accessToken, this.refreshToken, this.imsUserId, this.tokenType, this.expiresIn, this.expiration, this.scope);

  @override
  String toString() {
    return '$tokenType $accessToken';
  }

  bool isExpired() => DateTime.now().compareTo(expiration) > 0;

  factory IBMAuthentic.fromJson(Map<String, dynamic> json) {
    return IBMAuthentic._(
      json['access_token'],
      json['refresh_token'],
      json['ims_user_id'],
      json['token_type'],
      json['expires_in'],
      DateTime.fromMillisecondsSinceEpoch(json['expiration']),
      json['scope'].toString().split(" "),
    );
  }
}
