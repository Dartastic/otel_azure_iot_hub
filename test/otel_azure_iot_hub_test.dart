// Licensed under the Dartastic Pro Software License Agreement.
// Copyright 2025-2026 Mindful Software LLC d/b/a Dartastic.io, All rights reserved.

import 'package:otel_azure_iot_hub/otel_azure_iot_hub.dart';
import 'package:test/test.dart';

void main() {
  group('otel_azure_iot_hub', () {
    test('suppression toggles in zone', () async {
      expect(azureIoTHubInstrumentationSuppressed(), isFalse);
      await runWithoutAzureIoTHubInstrumentationAsync(() async {
        expect(azureIoTHubInstrumentationSuppressed(), isTrue);
      });
      expect(azureIoTHubInstrumentationSuppressed(), isFalse);
    });

    test('AzureIoTHubResult fields default null', () {
      const r = AzureIoTHubResult();
      expect(r.statusCode, isNull);
    });
  });
}
