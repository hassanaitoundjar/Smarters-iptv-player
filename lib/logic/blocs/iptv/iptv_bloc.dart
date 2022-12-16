import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';

import '../../../repository/api/api.dart';

part 'iptv_event.dart';
part 'iptv_state.dart';

class IptvBloc extends Bloc<IptvEvent, IptvState> {
  final IpTvApi authApi;
  IptvBloc(this.authApi) : super(IptvLoading()) {
    on<IptvDecodeContent>((event, emit) async {
      emit(IptvLoading());
    });

    on<IptvGetContentEvent>((event, emit) async {
      emit(IptvLoading());
    });
  }
}
