import 'package:dio/dio.dart';
import 'package:github_repo_app/core/infrastructure/dio_extensions.dart';
import 'package:github_repo_app/github/core/infrastructure/github_headers_cache.dart';
import 'package:github_repo_app/github/core/infrastructure/github_repo_dto.dart';
import 'package:path/path.dart';

import '../../../../core/infrastructure/network_exceptions.dart';
import '../../../../core/infrastructure/remote_response.dart';
import '../../../core/infrastructure/github_headers.dart';

class StarredReposRemoteService {
  final Dio _dio;
  final GithubHeadersCache _headersCache;

  StarredReposRemoteService(this._dio, this._headersCache);

  Future<RemoteResponse<List<GithubRepoDTO>>> getStarredReposPage(
      int page) async {
    final token = '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';
    final accept = 'application/vnd.github.v3.html+json';
    final requestUri = Uri.https(
      'api.github.com',
      '/user/starred',
      {'page': '$page'},
    );

    final previousHeaders = await _headersCache.getHeaders(requestUri);
    try {
      final response = await _dio.getUri(requestUri,
          options: Options(headers: {
            'Authorization': 'bearer $token',
            'Accept': accept,
            'If-None-Match': previousHeaders?.etag ?? '',
          }));

      if (response.statusCode == 304) {
        return RemoteResponse.notModified(
          maxPage: previousHeaders?.link?.maxPage ?? 0,
        );
      } else if (response.statusCode == 200) {
        final headers = GithubHeaders.parse(response);
        await _headersCache.saveHeaders(requestUri, headers);
        final convertedData = (response.data as List<dynamic>)
            .map((e) => GithubRepoDTO.fromJson(e as Map<String, dynamic>))
            .toList();
        return RemoteResponse.withNewData(convertedData,
            maxPage: headers.link?.maxPage ?? 1);
      } else {
        throw RestApiExceptions(response.statusCode);
      }
    } on DioError catch (e) {
      if (e.isNoConnectionError) {
        return const RemoteResponse.noConnection();
      } else if (e.response != null) {
        throw RestApiExceptions(e.response?.statusCode);
      } else {
        rethrow;
      }
    }
  }
}
