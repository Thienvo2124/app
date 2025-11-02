String dinhDangNgayGio(DateTime t) {
  final d = t.day.toString().padLeft(2, '0');
  final m = t.month.toString().padLeft(2, '0');
  final y = t.year.toString();
  final h = t.hour.toString().padLeft(2, '0');
  final mm = t.minute.toString().padLeft(2, '0');
  return '$h:$mm • $d/$m/$y';
}