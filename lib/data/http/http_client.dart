import 'package:http/http.dart' as http;

abstract class IHttpClient {
  Future get({required final String url});

  Future delete({required final String url});

  Future put({required final String url, required data, head});

  Future post({required final String url, required data});
}

class HttpClient implements IHttpClient {
  final client = http.Client();

  @override
  Future get({required String url}) async {
    return await client.get(Uri.parse(url));
  }

  @override
  Future delete({required String url}) async {
    return await client.delete(Uri.parse(url));
  }

  @override
  Future put({required String url, data, head}) async {
    return await client.put(Uri.parse(url), body: data, headers: head);
  }

  @override
  Future post({required String url, data}) async {
    return await client.post(Uri.parse(url), body: data);
  }
}
