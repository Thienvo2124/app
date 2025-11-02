import 'dart:convert';

class DonDatBan {
  final String id;
  final String nhaHangId;
  final String nhaHangTen;
  final String diaDiem;
  final String tenKhachHang;
  final String sdt;
  final int soNguoi;
  final DateTime thoiGian;
  final String ghiChu;

  DonDatBan({
    required this.id,
    required this.nhaHangId,
    required this.nhaHangTen,
    required this.diaDiem,
    required this.tenKhachHang,
    required this.sdt,
    required this.soNguoi,
    required this.thoiGian,
    required this.ghiChu,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nhaHangId': nhaHangId,
    'nhaHangTen': nhaHangTen,
    'diaDiem': diaDiem,
    'tenKhachHang': tenKhachHang,
    'sdt': sdt,
    'soNguoi': soNguoi,
    'thoiGian': thoiGian.toIso8601String(),
    'ghiChu': ghiChu,
  };

  factory DonDatBan.fromMap(Map<String, dynamic> m) => DonDatBan(
    id: m['id'] as String,
    nhaHangId: m['nhaHangId'] as String,
    nhaHangTen: m['nhaHangTen'] as String,
    diaDiem: m['diaDiem'] as String,
    tenKhachHang: m['tenKhachHang'] as String,
    sdt: m['sdt'] as String,
    soNguoi: (m['soNguoi'] as num).toInt(),
    thoiGian: DateTime.parse(m['thoiGian'] as String),
    ghiChu: (m['ghiChu'] ?? '') as String,
  );

  String toJson() => jsonEncode(toMap());
  factory DonDatBan.fromJson(String s) => DonDatBan.fromMap(jsonDecode(s));
}
