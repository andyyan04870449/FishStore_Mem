// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Device _$DeviceFromJson(Map<String, dynamic> json) => Device(
  deviceId: json['deviceId'] as String,
  jwt: json['jwt'] as String,
  lastSeen: DateTime.parse(json['lastSeen'] as String),
);

Map<String, dynamic> _$DeviceToJson(Device instance) => <String, dynamic>{
  'deviceId': instance.deviceId,
  'jwt': instance.jwt,
  'lastSeen': instance.lastSeen.toIso8601String(),
};

AuthRequest _$AuthRequestFromJson(Map<String, dynamic> json) =>
    AuthRequest(deviceCode: json['deviceCode'] as String);

Map<String, dynamic> _$AuthRequestToJson(AuthRequest instance) =>
    <String, dynamic>{'deviceCode': instance.deviceCode};

AuthResponse _$AuthResponseFromJson(Map<String, dynamic> json) => AuthResponse(
  jwt: json['jwt'] as String,
  deviceId: json['deviceId'] as String,
  expiresAt: DateTime.parse(json['expiresAt'] as String),
);

Map<String, dynamic> _$AuthResponseToJson(AuthResponse instance) =>
    <String, dynamic>{
      'jwt': instance.jwt,
      'deviceId': instance.deviceId,
      'expiresAt': instance.expiresAt.toIso8601String(),
    };
