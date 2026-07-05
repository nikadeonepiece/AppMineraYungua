import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:dio/io.dart';

import '../audit/security_audit_service.dart';

class SslPinningService {
  SslPinningService({required this.allowedSha256Fingerprints});

  final List<String> allowedSha256Fingerprints;

  void attach(Dio dio) {
    final adapter = dio.httpClientAdapter;
    if (adapter is! IOHttpClientAdapter) return;

    adapter.createHttpClient = () {
      final client = HttpClient();
      client.badCertificateCallback = (cert, host, port) {
        final allowed = allowedSha256Fingerprints;
        if (host == '10.0.2.2' || host == 'localhost') {
          return true;
        }
        if (allowed.isEmpty) {
          SecurityAuditService.instance.warn(
            'ssl_pinning_disabled',
            meta: {'host': host},
          );
          return false;
        }
        final digest = sha256.convert(cert.der).toString();
        final ok = allowed.any(
          (f) => f.toLowerCase().replaceAll(':', '') == digest.toLowerCase(),
        );
        if (!ok) {
          SecurityAuditService.instance.critical(
            'ssl_pinning_failed',
            meta: {'host': host, 'fingerprint': digest},
          );
        }
        return ok;
      };
      return client;
    };
  }
}
