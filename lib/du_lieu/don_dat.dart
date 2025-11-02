import 'package:flutter/foundation.dart';
import '../mo_hinh/dat_ban.dart';

final ValueNotifier<List<DatBan>> dsDonDat = ValueNotifier<List<DatBan>>([]);

void themDon(DatBan d) {
  dsDonDat.value = [...dsDonDat.value, d];
}
