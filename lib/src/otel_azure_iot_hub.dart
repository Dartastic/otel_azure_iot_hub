// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:dartastic_opentelemetry_api/dartastic_opentelemetry_api.dart';

import 'otel_azure_iot_hub_suppression.dart';

class AzureIoTHubResult {
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

class AzureIoTHubCallResult<T> {
  const AzureIoTHubCallResult({required this.value, this.result});
  final T value;
  final AzureIoTHubResult? result;
}

Future<T> tracedAzureIoTHub<T>({
  required String operation,
  required Future<AzureIoTHubCallResult<T>> Function() invoke,
  Tracer? tracer,
}) async {
  if (azureIoTHubInstrumentationSuppressed()) {
    final r = await invoke();
    return r.value;
  }
  final t = tracer ?? OTel.tracerProvider().getTracer('otel_azure_iot_hub');
  final span = t.startSpan('iothub $operation', kind: SpanKind.client);
  try {
    span.setStringAttribute('azure.service', 'iot_hub');
    span.setStringAttribute('messaging.system', 'azure_iot');
    final r = await invoke();
    final res = r.result;
    if (res != null) {
      if (res.subscriptionId != null) {
        span.setStringAttribute('azure.subscription.id', res.subscriptionId!);
      }
      if (res.resourceGroup != null) {
        span.setStringAttribute('azure.resource_group', res.resourceGroup!);
      }
      if (res.hubName != null) {
        span.setStringAttribute('azure.iot.hub.name', res.hubName!);
      }
      if (res.deviceId != null) {
        span.setStringAttribute('messaging.client_id', res.deviceId!);
      }
      if (res.moduleId != null) {
        span.setStringAttribute('azure.iot.module.id', res.moduleId!);
      }
      if (res.topic != null) {
        span.setStringAttribute('messaging.destination.name', res.topic!);
      }
      if (res.direction != null) {
        span.setStringAttribute('azure.iot.direction', res.direction!);
      }
      if (res.twinVersion != null) {
        span.setIntAttribute('azure.iot.twin.version', res.twinVersion!);
      }
      if (res.jobId != null) {
        span.setStringAttribute('azure.iot.job.id', res.jobId!);
      }
      if (res.region != null) {
        span.setStringAttribute('cloud.region', res.region!);
      }
      if (res.statusCode != null) {
        span.setIntAttribute('http.response.status_code', res.statusCode!);
      }
      if (res.errorCode != null) {
        span.setStringAttribute('iothub.error.code', res.errorCode!);
      }
      final fail =
          res.errorCode != null ||
          (res.statusCode != null && res.statusCode! >= 400);
      if (fail) {
        span.setStringAttribute(
          ErrorResource.errorType.key,
          res.errorCode ?? 'iothub.error',
        );
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
