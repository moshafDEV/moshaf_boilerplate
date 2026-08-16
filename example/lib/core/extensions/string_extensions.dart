extension StringPascalCase on String {
  String get toPascalCase {
    if (isEmpty) return this;
    return split(' ').map((w) {
      if (w.isEmpty) return w;
      return w[0].toUpperCase() + w.substring(1).toLowerCase();
    }).join(' ');
  }
}
