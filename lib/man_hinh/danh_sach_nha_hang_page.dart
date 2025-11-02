// lib/man_hinh/danh_sach_nha_hang_page.dart
import 'package:flutter/material.dart';

import '../du_lieu/gia_lap.dart'; // dữ liệu cục bộ tạm thời
import '../mo_hinh/nha_hang.dart';
import 'chi_tiet_nha_hang_page.dart';

class DanhSachNhaHangPage extends StatefulWidget {
  const DanhSachNhaHangPage({super.key});

  @override
  State<DanhSachNhaHangPage> createState() => _DanhSachNhaHangPageState();
}

enum SortOption { ratingDesc, nameAsc }

class _DanhSachNhaHangPageState extends State<DanhSachNhaHangPage> {
  // ==== state lọc/sắp xếp ====
  final Set<String> _cities = {};
  final Set<String> _cuisines = {};
  double _minRating = 0.0; // sẽ lưu 0..5 (số nguyên dưới dạng double)
  SortOption _sort = SortOption.ratingDesc;

  @override
  Widget build(BuildContext context) {
    // TODO: nếu chuyển sang Firestore, thay "all = [...dsNhaHang]" bằng list từ snapshot
    List<NhaHang> all = [...dsNhaHang];

    // ==== danh sách option để hiển thị trong bottom sheet ====
    final allCities = {
      for (final n in all) n.thanhPho,
    }.toList()
      ..sort();
    final allCuisines = {
      for (final n in all) n.amThuc,
    }.toList()
      ..sort();

    // ==== áp dụng lọc ====
    List<NhaHang> filtered = all.where((n) {
      final okCity = _cities.isEmpty || _cities.contains(n.thanhPho);
      final okCuisine = _cuisines.isEmpty || _cuisines.contains(n.amThuc);
      final okRating = n.danhGia >= _minRating; // chọn 4 -> giữ 4.0, 4.3, 4.7...
      return okCity && okCuisine && okRating;
    }).toList();

    // ==== sắp xếp ====
    switch (_sort) {
      case SortOption.ratingDesc:
        filtered.sort((a, b) => b.danhGia.compareTo(a.danhGia));
        break;
      case SortOption.nameAsc:
        filtered.sort((a, b) => a.ten.compareTo(b.ten));
        break;
    }

    // ==== chia "nổi bật" & "gợi ý" ====
    final featured = filtered.take(6).toList();
    final goiY = filtered.length > 6 ? filtered.sublist(6) : filtered;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header có menu 3 gạch – gọi callback để mở sheet/đặt lại
            SliverToBoxAdapter(
              child: _HeaderWhite(
                onFilter: () async {
                  final result = await showModalBottomSheet<_FilterResult>(
                    context: context,
                    isScrollControlled: true,
                    builder: (_) => _FilterSheet(
                      allCities: allCities,
                      allCuisines: allCuisines,
                      selectedCities: _cities,
                      selectedCuisines: _cuisines,
                      minRating: _minRating,
                      sort: _sort,
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _cities
                        ..clear()
                        ..addAll(result.cities);
                      _cuisines
                        ..clear()
                        ..addAll(result.cuisines);
                      _minRating = result.minRating;
                      _sort = result.sort;
                    });
                  }
                },
                onSort: () async {
                  final next =
                  _sort == SortOption.ratingDesc ? SortOption.nameAsc : SortOption.ratingDesc;
                  setState(() => _sort = next);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(next == SortOption.ratingDesc
                          ? 'Sắp xếp: Đánh giá cao → thấp'
                          : 'Sắp xếp: Tên A → Z'),
                    ),
                  );
                },
                onReset: () {
                  setState(() {
                    _cities.clear();
                    _cuisines.clear();
                    _minRating = 0;
                    _sort = SortOption.ratingDesc;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đặt lại bộ lọc')),
                  );
                },
              ),
            ),

            // ===== Tiêu đề "Nhà hàng nổi bật"
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Nhà hàng nổi bật',
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                      ),
                    ),
                    _SectionMenu(),
                  ],
                ),
              ),
            ),

            // ===== Dải ngang: Nổi bật
            SliverToBoxAdapter(
              child: SizedBox(
                height: 280,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) => _BigCard(n: featured[i]),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: featured.length,
                ),
              ),
            ),

            // ===== Tiêu đề "Gợi ý cho bạn"
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(16, 20, 16, 12),
                child: Text(
                  'Gợi ý cho bạn',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ),
            ),

            // ===== Dải ngang: Gợi ý
            SliverToBoxAdapter(
              child: SizedBox(
                height: 240,
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) => _SmallCard(n: goiY[i]),
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemCount: goiY.length,
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 24)),
          ],
        ),
      ),
    );
  }
}

class _HeaderWhite extends StatelessWidget {
  final VoidCallback onFilter;
  final VoidCallback onSort;
  final VoidCallback onReset;

  const _HeaderWhite({
    required this.onFilter,
    required this.onSort,
    required this.onReset,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 140,
      child: Stack(
        children: [
          Positioned.fill(
            child: ClipPath(
              clipper: _ArcClipper(),
              child: Container(color: Colors.white),
            ),
          ),
          Positioned(left: 0, right: 0, bottom: 0, child: _BottomShadow()),
          Positioned.fill(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Nhà hàng nổi bật',
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  PopupMenuButton<_MenuAction>(
                    icon: const Icon(Icons.menu, color: Colors.black87),
                    onSelected: (v) {
                      switch (v) {
                        case _MenuAction.filter:
                          onFilter();
                          break;
                        case _MenuAction.sort:
                          onSort();
                          break;
                        case _MenuAction.reset:
                          onReset();
                          break;
                      }
                    },
                    itemBuilder: (ctx) => const [
                      PopupMenuItem(
                        value: _MenuAction.filter,
                        child: ListTile(
                          leading: Icon(Icons.filter_list),
                          title: Text('Lọc…'),
                        ),
                      ),
                      PopupMenuItem(
                        value: _MenuAction.sort,
                        child: ListTile(
                          leading: Icon(Icons.sort),
                          title: Text('Đổi kiểu sắp xếp'),
                        ),
                      ),
                      PopupMenuItem(
                        value: _MenuAction.reset,
                        child: ListTile(
                          leading: Icon(Icons.restart_alt),
                          title: Text('Đặt lại bộ lọc'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Menu nhỏ ở tiêu đề section (nếu cần)
class _SectionMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      onSelected: (_) {},
      itemBuilder: (_) => const [
        PopupMenuItem(value: 'a', child: Text('Chỉ hiện 4 mục')),
        PopupMenuItem(value: 'b', child: Text('Xem tất cả')),
      ],
      icon: const Icon(Icons.more_horiz),
    );
  }
}

enum _MenuAction { filter, sort, reset }

/// Kết quả từ sheet lọc
class _FilterResult {
  final Set<String> cities;
  final Set<String> cuisines;
  final double minRating; // 0..5 (nguyên)
  final SortOption sort;

  _FilterResult({
    required this.cities,
    required this.cuisines,
    required this.minRating,
    required this.sort,
  });
}

/// BottomSheet lọc/sắp xếp
class _FilterSheet extends StatefulWidget {
  final List<String> allCities;
  final List<String> allCuisines;
  final Set<String> selectedCities;
  final Set<String> selectedCuisines;
  final double minRating; // 0..5
  final SortOption sort;

  const _FilterSheet({
    required this.allCities,
    required this.allCuisines,
    required this.selectedCities,
    required this.selectedCuisines,
    required this.minRating,
    required this.sort,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  late Set<String> _cities;
  late Set<String> _cuisines;
  late double _minRating; // lưu 0..5
  late SortOption _sort;

  @override
  void initState() {
    super.initState();
    _cities = {...widget.selectedCities};
    _cuisines = {...widget.selectedCuisines};
    _minRating = widget.minRating;
    _sort = widget.sort;
  }

  @override
  Widget build(BuildContext context) {
    // để nội dung cao > 50% màn hình thì cuộn mượt
    final view = MediaQuery.of(context).viewInsets;
    return Padding(
      padding: EdgeInsets.only(bottom: view.bottom),
      child: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: SizedBox(
                  width: 40,
                  child: Divider(thickness: 3),
                ),
              ),
              const SizedBox(height: 8),
              const Text('Lọc theo',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),

              const SizedBox(height: 12),
              const Text('Thành phố',
                  style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: -4,
                children: widget.allCities.map((c) {
                  final selected = _cities.contains(c);
                  return FilterChip(
                    label: Text(c),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _cities.add(c);
                        } else {
                          _cities.remove(c);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 12),
              const Text('Ẩm thực', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: -4,
                children: widget.allCuisines.map((c) {
                  final selected = _cuisines.contains(c);
                  return FilterChip(
                    label: Text(c),
                    selected: selected,
                    onSelected: (v) {
                      setState(() {
                        if (v) {
                          _cuisines.add(c);
                        } else {
                          _cuisines.remove(c);
                        }
                      });
                    },
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Đánh giá tối thiểu'),
                  const SizedBox(width: 12),
                  Text('${_minRating.toInt()}★'),
                ],
              ),
              // Slider 0..5 số nguyên
              Slider(
                value: _minRating,
                min: 0,
                max: 5,
                divisions: 5, // chỉ 0,1,2,3,4,5
                label: '${_minRating.toInt()}★',
                onChanged: (v) => setState(() => _minRating = v.roundToDouble()),
              ),

              const SizedBox(height: 8),
              const Text('Sắp xếp', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              SegmentedButton<SortOption>(
                segments: const [
                  ButtonSegment(value: SortOption.ratingDesc, label: Text('Đánh giá')),
                  ButtonSegment(value: SortOption.nameAsc, label: Text('Tên A→Z')),
                ],
                selected: {_sort},
                onSelectionChanged: (s) => setState(() => _sort = s.first),
              ),

              const SizedBox(height: 16),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _cities.clear();
                        _cuisines.clear();
                        _minRating = 0; // về 0 => hiện tất cả
                        _sort = SortOption.ratingDesc;
                      });
                    },
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Đặt lại'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () {
                      Navigator.pop(
                        context,
                        _FilterResult(
                          cities: _cities,
                          cuisines: _cuisines,
                          minRating: _minRating,
                          sort: _sort,
                        ),
                      );
                    },
                    child: const Text('Áp dụng'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BottomShadow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: const BoxDecoration(
        boxShadow: [BoxShadow(color: Color(0x11000000), blurRadius: 6, offset: Offset(0, 2))],
      ),
    );
  }
}

/// Card lớn (dải "Nổi bật")
class _BigCard extends StatelessWidget {
  final NhaHang n;
  const _BigCard({required this.n});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 160,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChiTietNhaHangPage(nhaHang: n)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'nhahang_${n.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    n.anh,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              n.ten,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: Colors.black87),
            ),
            Text(
              n.thanhPho,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const SizedBox(height: 2),
            _Stars(rating: n.danhGia, size: 16),
          ],
        ),
      ),
    );
  }
}

/// Card nhỏ (dải "Gợi ý cho bạn")
class _SmallCard extends StatelessWidget {
  final NhaHang n;
  const _SmallCard({required this.n});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ChiTietNhaHangPage(nhaHang: n)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Hero(
                tag: 'nhahang_${n.id}',
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(14),
                  child: Image.network(
                    n.anh,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey.shade300,
                      alignment: Alignment.center,
                      child: const Icon(Icons.image_not_supported_outlined),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              n.ten,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Colors.black87),
            ),
            Text(
              n.thanhPho,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
            ),
            const SizedBox(height: 2),
            _Stars(rating: n.danhGia, size: 14),
          ],
        ),
      ),
    );
  }
}

/// Sao đánh giá
class _Stars extends StatelessWidget {
  final double rating;
  final double size;
  const _Stars({required this.rating, this.size = 18});

  @override
  Widget build(BuildContext context) {
    final full = rating.floor();
    final half = (rating - full) >= 0.5;
    const total = 5;
    final icons = <Widget>[];

    for (int i = 0; i < full; i++) {
      icons.add(Icon(Icons.star_rounded, size: size, color: Colors.amber));
    }
    if (half) icons.add(Icon(Icons.star_half_rounded, size: size, color: Colors.amber));
    while (icons.length < total) {
      icons.add(Icon(Icons.star_border_rounded, size: size, color: Colors.amber));
    }

    return Row(mainAxisSize: MainAxisSize.min, children: icons.take(total).toList());
  }
}

/// Cắt cong phần đáy header
class _ArcClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path()..lineTo(0, size.height - 40);
    final control = Offset(size.width / 2, size.height + 40);
    final end = Offset(size.width, size.height - 40);
    path.quadraticBezierTo(control.dx, control.dy, end.dx, end.dy);
    path.lineTo(size.width, 0);
    path.close();
    return path;
  }
  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
