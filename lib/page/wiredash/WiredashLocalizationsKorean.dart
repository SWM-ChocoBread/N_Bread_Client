import 'package:wiredash/assets/l10n/wiredash_localizations_en.g.dart';

class WiredashLocalizationsKorean extends WiredashLocalizationsEn {
  WiredashLocalizationsKorean() : super('ko');

  // @override
  // String get promoterScoreStep2MessageDescription =>
  //     "Could you tell us a bit more about why you chose {rating}? This step is optional.";

  @override
  String get promoterScoreStep2MessageTitle => "해당 점수를 준 이유를 적어주세요.";

  @override
  String get promoterScoreStep1Question => "앱을 0 - 10점 사이로 평가해주세요";

  @override
  String get promoterScoreStep1Description => "0 = 별로에요, 10 = 아주 좋아요";

  @override
  String get promoterScoreStep3ThanksMessagePromoters => "평가해주셔서 감사합니다!";

  @override
  String get promoterScoreStep2MessageHint => "앱 개선에 큰 도움이 됩니다.";

  @override
  String promoterScoreStep2MessageDescription(int rating) {
    return '$rating점을 주신 이유를 적어주세요!';
  }

  @override
  String get backdropReturnToApp => '앱으로 돌아가기';

    @override
  String get promoterScoreNextButton => '다음';

  @override
  String get promoterScoreBackButton => '이전';

  @override
  String get promoterScoreSubmitButton => '제출';
}
