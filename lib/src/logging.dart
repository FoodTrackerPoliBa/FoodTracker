import 'package:talker/talker.dart';
import 'package:talker_http_logger/talker_http_logger.dart';
import 'package:http_interceptor/http_interceptor.dart';

final Talker logging = Talker();

final InterceptedClient httpClientWithLogger = InterceptedClient.build(interceptors: [
  TalkerHttpLogger(talker: logging),
]);
