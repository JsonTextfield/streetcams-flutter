import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../blocs/camera_bloc.dart';
import '../../../entities/Cities.dart';

class ChangeCityMenu extends StatelessWidget {
  const ChangeCityMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        void changeCity(Cities city) {
          context.read<CameraBloc>().changeCity(city);
        }

        return MenuAnchor(
          builder: (context, menu, child) {
            return IconButton(
              onPressed: () => menu.isOpen ? menu.close() : menu.open(),
              icon: const Icon(Icons.location_city_rounded),
              tooltip: AppLocalizations.of(context)!.city,
            );
          },
          menuChildren: [
            RadioMenuButton<Cities>(
              value: Cities.ottawa,
              groupValue: state.city,
              onChanged: (_) => changeCity(Cities.ottawa),
              child: Text(AppLocalizations.of(context)!.ottawa),
            ),
            RadioMenuButton<Cities>(
              value: Cities.toronto,
              groupValue: state.city,
              onChanged: (_) => changeCity(Cities.toronto),
              child: Text(AppLocalizations.of(context)!.toronto),
            ),
            RadioMenuButton<Cities>(
              value: Cities.montreal,
              groupValue: state.city,
              onChanged: (_) => changeCity(Cities.montreal),
              child: Text(AppLocalizations.of(context)!.montreal),
            ),
            RadioMenuButton<Cities>(
              value: Cities.calgary,
              groupValue: state.city,
              onChanged: (_) => changeCity(Cities.calgary),
              child: Text(AppLocalizations.of(context)!.calgary),
            ),
          ],
        );
      },
    );
  }
}
