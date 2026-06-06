/// 宠物类型与 API 文档对齐（pet_type 使用中文，如「猫」「狗」）
class PetTypeHelper {
  static const List<String> displayTypes = ['猫', '狗', '兔子', '仓鼠', '鸟', '鱼', '其他'];

  /// Mock/旧数据中的英文类型转为 API 中文
  static String toDisplayType(String raw) {
    switch (raw.toLowerCase()) {
      case 'cat':
        return '猫';
      case 'dog':
        return '狗';
      case 'rabbit':
        return '兔子';
      case 'hamster':
        return '仓鼠';
      case 'bird':
        return '鸟';
      case 'fish':
        return '鱼';
      default:
        return displayTypes.contains(raw) ? raw : '其他';
    }
  }

  /// 提交给 POST/PUT /api/pets 的 pet_type 字段
  static String toApiType(String display) => display;
}
