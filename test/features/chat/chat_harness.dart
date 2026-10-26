import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hermes/features/chat/domain/outbox.dart';
import 'package:hermes/features/chat/presentation/chat_view.dart';
import 'package:hermes/hermes/events/gateway_event.dart';
import 'package:hermes/hermes/hermes_failure.dart';
import 'package:hermes/hermes/models/local_attachment.dart';

import '../../support/app_host.dart';
import '../../support/scripted_api.dart';

/// A submit whose frame went out and got no answer.
const lost = OutcomeUnknownFailure('socket closed after the request was sent');

final t0 = DateTime.now().toUtc();

OutboxEntry entry(
  String id,
  String text, {
  OutboxStatus status = OutboxStatus.queued,
  int attempts = 0,
}) => OutboxEntry(
  id: id,
  createdAt: t0,
  text: text,
  status: status,
  attempts: attempts,
);

/// A live event of the session `rt-1`.
GatewayEvent ev(String type, [Map<String, dynamic> payload = const {}]) =>
    GatewayEvent(type: type, sessionId: 'rt-1', payload: payload);

/// A picture of [bytes] in a temp folder.
Future<LocalAttachment> tempImage({int bytes = 8}) async {
  final dir = await Directory.systemTemp.createTemp('chat_test');
  addTearDown(() => dir.delete(recursive: true));
  final file = File('${dir.path}/pic.png');
  await file.writeAsBytes(List<int>.filled(bytes, 7));
  return LocalAttachment(
    id: 'a1',
    path: file.path,
    name: 'pic.png',
    mimeType: 'image/png',
    sizeBytes: bytes,
    kind: AttachmentKind.image,
  );
}

/// The whole chat screen of [rig], on a phone.
Future<void> pumpChat(
  WidgetTester tester,
  ChatRig rig, {
  double width = 400,
  double height = 800,
}) async {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    appHost(ChatView(target: rig.target), container: rig.container),
  );
  await tester.pumpAndSettle();
}
