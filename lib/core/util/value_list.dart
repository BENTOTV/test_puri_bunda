/// "first value" or "first value · +N more" for a label field that may
/// repeat (brand/generic/manufacturer names can all have several values).
String firstPlusMore(
  List<String> values,
  String Function(int extra) moreLabel,
) {
  if (values.isEmpty) return '';
  if (values.length == 1) return values.first;
  return '${values.first} · ${moreLabel(values.length - 1)}';
}
