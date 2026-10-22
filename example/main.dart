// Licensed under the Apache License, Version 2.0
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:dartastic_opentelemetry/dartastic_opentelemetry.dart';
import 'package:otel_azure_iot_hub/otel_azure_iot_hub.dart';

/// Traces Azure Iot Hub calls with OpenTelemetry.
///
/// `otel_azure_iot_hub` depends on the OpenTelemetry API only, so the application
/// initializes an SDK once at startup. Wrap each Azure Iot Hub call in
/// [tracedAzureIoTHub]; the `invoke` callback makes the real call and reports what
/// came back, which is recorded on the span.
Future<void> main() async {
  await OTel.initialize(serviceName: 'azure-iot-hub-example');

  // Traces a Azure Iot Hub call.
  final azureIoTHubId = await tracedAzureIoTHub<String>(
    operation: 'create',
    invoke: () async {
      // Make the Azure Iot Hub call here, then report what it returned.
      const id = 'azure_iot_hub_8f3a2c';
      return const AzureIoTHubCallResult(
          value: id,
          result: AzureIoTHubResult(
              subscriptionId: 'subscription_8f3a2c',
              resourceGroup: 'Order',
              hubName: 'example',
              deviceId: 'device_8f3a2c',
              moduleId: 'module_8f3a2c',
              topic: 'orders',
              direction: 'example',
              twinVersion: 1,
              jobId: 'job_8f3a2c',
              region: 'us-east-1',
              statusCode: 201,
              errorCode: 'example',
              errorMessage: 'example'));
    },
  );
  OTelLog.info('tracedAzureIoTHub create returned $azureIoTHubId');

  // Calls that should not be traced, such as health checks, run inside
  // runWithoutAzureIoTHubInstrumentationAsync.
  await runWithoutAzureIoTHubInstrumentationAsync(
    () => tracedAzureIoTHub<String>(
      operation: 'create',
      invoke: () async {
        const id = 'azure_iot_hub_8f3a2c';
        return const AzureIoTHubCallResult(
            value: id,
            result: AzureIoTHubResult(
                subscriptionId: 'subscription_8f3a2c',
                resourceGroup: 'Order',
                hubName: 'example',
                deviceId: 'device_8f3a2c',
                moduleId: 'module_8f3a2c',
                topic: 'orders',
                direction: 'example',
                twinVersion: 1,
                jobId: 'job_8f3a2c',
                region: 'us-east-1',
                statusCode: 201,
                errorCode: 'example',
                errorMessage: 'example'));
      },
    ),
  );

  await OTel.shutdown();
}
