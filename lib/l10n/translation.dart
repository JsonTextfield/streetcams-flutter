import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

extension Translation on BuildContext {
  AppLocalizations get translation => AppLocalizations.of(this);
}
