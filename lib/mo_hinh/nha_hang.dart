class NhaHang {
  final String id;
  final String ten;
  final String thanhPho;
  final String amThuc;
  final String diaChi;
  final double danhGia; // 0..5
  final String anh;
  final String moTa;


  const NhaHang({
    required this.id,
    required this.ten,
    required this.thanhPho,
    required this.amThuc,
    required this.diaChi,
    required this.danhGia,
    required this.anh,
    required this.moTa,
  });
}