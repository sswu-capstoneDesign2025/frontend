// 상태 관리 (예: 로그인 상태, 에러 처리 등)

import 'package:flutter_riverpod/flutter_riverpod.dart';

final kakaoLoginStateProvider = StateProvider<KakaoLoginState>((ref) => KakaoLoginState.initial);

enum KakaoLoginState {
  initial,
  loading,
  success,
  error,
}
