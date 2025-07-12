import 'package:json_annotation/json_annotation.dart';

part 'auth.g.dart';

@JsonSerializable()
class Device {
  final String deviceId;
  final String jwt;
  final DateTime lastSeen;

  Device({
    required this.deviceId,
    required this.jwt,
    required this.lastSeen,
  });

  factory Device.fromJson(Map<String, dynamic> json) => _$DeviceFromJson(json);
  Map<String, dynamic> toJson() => _$DeviceToJson(this);

  Device copyWith({
    String? deviceId,
    String? jwt,
    DateTime? lastSeen,
  }) {
    return Device(
      deviceId: deviceId ?? this.deviceId,
      jwt: jwt ?? this.jwt,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }
}

@JsonSerializable()
class AuthRequest {
  final String deviceCode;

  AuthRequest({
    required this.deviceCode,
  });

  factory AuthRequest.fromJson(Map<String, dynamic> json) => _$AuthRequestFromJson(json);
  Map<String, dynamic> toJson() => _$AuthRequestToJson(this);
}

@JsonSerializable()
class AuthResponse {
  final String jwt;
  final String deviceId;
  final DateTime expiresAt;

  AuthResponse({
    required this.jwt,
    required this.deviceId,
    required this.expiresAt,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) => _$AuthResponseFromJson(json);
  Map<String, dynamic> toJson() => _$AuthResponseToJson(this);
} 