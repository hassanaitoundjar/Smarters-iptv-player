import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:get_storage/get_storage.dart';

import '../models/category.dart';
import '../models/channelLive.dart';
import '../models/user.dart';

part '../locale/locale.dart';
part 'auth.dart';
part 'iptv.dart';

final _dio = Dio();
final locale = GetStorage();
