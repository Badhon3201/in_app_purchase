class InAppItemId{
  static const String nonConsumableIdForAdRemove = "com.riseuplabs.islamicquote.removeads";
  static String kUpgradeId = 'upgrade';
  static String kSilverSubscriptionId = 'subscription_silver';
  static String kGoldSubscriptionId = 'subscription_gold';
  static List<String> kProductIds = <String>[
    InAppItemId.nonConsumableIdForAdRemove,
    kUpgradeId,
    kSilverSubscriptionId,
    kGoldSubscriptionId,
  ];
}