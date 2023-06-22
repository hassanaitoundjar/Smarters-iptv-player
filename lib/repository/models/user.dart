class UserModel {
  final UserInfo? userInfo;
  final ServerInfo? serverInfo;

  UserModel({
    this.userInfo,
    this.serverInfo,
  });

  UserModel.fromJson(Map<String, dynamic> json, String domain)
      : userInfo = (json['user_info'] as Map<String, dynamic>?) != null
            ? UserInfo.fromJson(json['user_info'] as Map<String, dynamic>)
            : null,
        serverInfo = (json['server_info'] as Map<String, dynamic>?) != null
            ? ServerInfo.fromJson(
                json['server_info'] as Map<String, dynamic>, domain)
            : null;

  Map<String, dynamic> toJson() => {
        'user_info': userInfo?.toJson(),
        'server_info': serverInfo?.toJson(),
      };
}

class UserInfo {
  final String? username;
  final String? password;
  final String? message;
  final String? auth;
  final String? status;
  final String? expDate;
  final String? isTrial;
  final String? activeCons;
  final String? createdAt;
  final String? maxConnections;
  final List<String>? allowedOutputFormats;

  UserInfo({
    this.username,
    this.password,
    this.message,
    this.auth,
    this.status,
    this.expDate,
    this.isTrial,
    this.activeCons,
    this.createdAt,
    this.maxConnections,
    this.allowedOutputFormats,
  });

  UserInfo.fromJson(Map<String, dynamic> json)
      : username = json['username'].toString(),
        password = json['password'].toString(),
        message = json['message'].toString(),
        auth = json['auth'].toString(),
        status = json['status'].toString(),
        expDate = json['exp_date'] as String?,
        isTrial = json['is_trial'].toString(),
        activeCons = json['active_cons'].toString(),
        createdAt = json['created_at'].toString(),
        maxConnections = json['max_connections'].toString(),
        allowedOutputFormats = (json['allowed_output_formats'] as List?)
            ?.map((dynamic e) => e.toString())
            .toList();

  Map<String, dynamic> toJson() => {
        'username': username,
        'password': password,
        'message': message,
        'auth': auth,
        'status': status,
        'exp_date': expDate,
        'is_trial': isTrial,
        'active_cons': activeCons,
        'created_at': createdAt,
        'max_connections': maxConnections,
        'allowed_output_formats': allowedOutputFormats
      };
}

class ServerInfo {
  final String? url;
  final String? port;
  final String? httpsPort;
  final String? serverProtocol;
  final String? rtmpPort;
  final String? timezone;
  final String? timestampNow;
  final String? timeNow;
  final String? process;
  final String? serverUrl;

  ServerInfo({
    this.serverUrl,
    this.url,
    this.port,
    this.httpsPort,
    this.serverProtocol,
    this.rtmpPort,
    this.timezone,
    this.timestampNow,
    this.timeNow,
    this.process,
  });

  ServerInfo.fromJson(Map<String, dynamic> json, String domain)
      : url = json['url'].toString(),
        port = json['port'].toString(),
        httpsPort = json['https_port'].toString(),
        serverProtocol = json['server_protocol'].toString(),
        rtmpPort = json['rtmp_port'].toString(),
        timezone = json['timezone'].toString(),
        timestampNow = json['timestamp_now'].toString(),
        timeNow = json['time_now'].toString(),
        process = json['process'].toString(),
        serverUrl = (json['server_url'] ?? domain).toString();

  Map<String, dynamic> toJson() => {
        'url': url,
        'port': port,
        'https_port': httpsPort,
        'server_protocol': serverProtocol,
        'rtmp_port': rtmpPort,
        'timezone': timezone,
        'timestamp_now': timestampNow,
        'time_now': timeNow,
        'process': process,
        'server_url': serverUrl
      };
}
