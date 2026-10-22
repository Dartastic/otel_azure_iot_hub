// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_azure_iot_hub_suppression.dart';

class AzureIoTHubResult {
  /// Creates a result.
  const AzureIoTHubResult({
    this.subscriptionId,
    this.resourceGroup,
    this.hubName,
    this.deviceId,
    this.moduleId,
    this.topic,
    this.direction,
    this.twinVersion,
    this.jobId,
    this.region,
    this.statusCode,
    this.errorCode,
    this.errorMessage,
  });

  final String? subscriptionId;
  final String? resourceGroup;
  final String? hubName;
  final String? deviceId;
  final String? moduleId;
  final String? topic;
  final String? direction;
  final int? twinVersion;
  final String? jobId;
  final String? region;
  final int? statusCode;
  final String? errorCode;
  final String? errorMessage;
}

/// What a traced call returned: the value for the caller plus fields
/// recorded on the span.
class AzureIoTHubCallResult<T> {
  /// Creates a call result.
  const AzureIoTHubCallResult({required this.value, this.result});

  /// The value returned to the caller.
  final T value;
  final AzureIoTHubResult? result;
}

Future<T> tracedAzureIoTHub<T>({
  required String operation,
  required Future<AzureIoTHubCallResult<T>> Function() invoke,
  APITracer? tracer,
}) async {
  if (azureIoTHubInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTelAPI.tracerProvider().getTracer('otel_azure_iot_hub');
  final span = t.startSpan('iothub $operation', kind: SpanKind.client);
  try {
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('azure.service', 'iot_hub')]));
    span.addAttributes(OTelAPI.attributes(
        [OTelAPI.attributeString('messaging.system', 'azure_iot')]));
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.subscriptionId != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('azure.subscription.id', res.subscriptionId!)
        ]));
      }
      if (res.resourceGroup != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('azure.resource_group', res.resourceGroup!)
        ]));
      }
      if (res.hubName != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('azure.iot.hub.name', res.hubName!)]));
      }
      if (res.deviceId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('messaging.client_id', res.deviceId!)]));
      }
      if (res.moduleId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('azure.iot.module.id', res.moduleId!)]));
      }
      if (res.topic != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString('messaging.destination.name', res.topic!)
        ]));
      }
      if (res.direction != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('azure.iot.direction', res.direction!)]));
      }
      if (res.twinVersion != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('azure.iot.twin.version', res.twinVersion!)
        ]));
      }
      if (res.jobId != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('azure.iot.job.id', res.jobId!)]));
      }
      if (res.region != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('cloud.region', res.region!)]));
      }
      if (res.statusCode != null) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeInt('http.response.status_code', res.statusCode!)
        ]));
      }
      if (res.errorCode != null) {
        span.addAttributes(OTelAPI.attributes(
            [OTelAPI.attributeString('iothub.error.code', res.errorCode!)]));
      }
      final fail = res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.addAttributes(OTelAPI.attributes([
          OTelAPI.attributeString(
            ErrorAttributes.errorType.key,
            res.errorCode ?? 'iothub.error',
          )
        ]));
        span.setStatus(SpanStatusCode.Error, res.errorMessage);
      }
    }
    return r.value;
  } catch (e, st) {
    span.recordException(e, stackTrace: st);
    span.setStatus(SpanStatusCode.Error, e.toString());
    rethrow;
  } finally {
    span.end();
  }
}
