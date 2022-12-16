import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vlc_player/flutter_vlc_player.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../helpers/helpers.dart';
import '../../logic/blocs/auth/auth_bloc.dart';
import '../../logic/blocs/categories/channels/channels_bloc.dart';
import '../../logic/blocs/categories/live/live_caty_bloc.dart';
import '../../logic/cubits/video/video_cubit.dart';
import '../widgets/widgets.dart';

part 'live/live_categories.dart';
part 'live/live_channels.dart';
part 'player/full_video.dart';
part 'player/player_video.dart';
part 'user/register.dart';
part 'user/splash.dart';
part 'welcome.dart';
