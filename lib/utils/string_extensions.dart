extension MyStringExtension on String {
  String get capitalize {
    if (isEmpty) return this;

    return "${this[0].toUpperCase()}${substring(1)}";
  }
  String get capitalizeAll {
    if (isEmpty) return this;

    return split(' ').map((el) => el.capitalize).join(' ');
  }
}