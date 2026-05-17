# otel_azure_iot_hub

Dartastic OpenTelemetry bridge for Azure IoT Hub (device-to-cloud messaging + twins + jobs).

Wraps each call in a CLIENT-kind span with vendor-specific attributes following OpenTelemetry semantic conventions where applicable.

```dart
import 'package:otel_azure_iot_hub/otel_azure_iot_hub.dart';

await tracedAzureIoTHub<void>(
  operation: 'someOp',
  invoke: () async {
    final r = await client.someOp();
    return AzureIoTHubCallResult(value: r, result: AzureIoTHubResult(statusCode: 200));
  },
);
```

Suppress instrumentation within a block:

```dart
await runWithoutAzureIoTHubInstrumentationAsync(() async {
  await client.someInternalSync();
});
```
