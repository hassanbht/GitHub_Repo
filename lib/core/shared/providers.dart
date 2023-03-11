import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../infrastructure/sembast_database.dart';

final sembaseProvider = Provider((ref) => SembastDatabase());
