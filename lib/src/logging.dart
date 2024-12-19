import 'package:talker_flutter/talker_flutter.dart';
import 'package:talker_http_logger/talker_http_logger.dart';
import 'package:http_interceptor/http_interceptor.dart';

final Talker logging =
    TalkerFlutter.init(logger: TalkerLogger(settings: TalkerLoggerSettings()));

final InterceptedClient httpClientWithLogger =
    InterceptedClient.build(interceptors: [
  TalkerHttpLogger(talker: logging),
]);
