import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../../blocs/camera_bloc.dart';
import '../../../entities/city.dart';

class ChangeCityMenu extends StatelessWidget {
  const ChangeCityMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CameraBloc, CameraState>(
      builder: (context, state) {
        void changeCity(City city) {
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
            RadioMenuButton<City>(
              value: City.ottawa,
              groupValue: state.city,
              onChanged: (_) => changeCity(City.ottawa),
              child: Text(AppLocalizations.of(context)!.ottawa),
            ),
            RadioMenuButton<City>(
              value: City.toronto,
              groupValue: state.city,
              onChanged: (_) => changeCity(City.toronto),
              child: Text(AppLocalizations.of(context)!.toronto),
            ),
            RadioMenuButton<City>(
              value: City.montreal,
              groupValue: state.city,
              onChanged: (_) => changeCity(City.montreal),
              child: Text(AppLocalizations.of(context)!.montreal),
            ),
            RadioMenuButton<City>(
              value: City.calgary,
              groupValue: state.city,
              onChanged: (_) => changeCity(City.calgary),
              child: Text(AppLocalizations.of(context)!.calgary),
            ),
            RadioMenuButton<City>(
              value: City.vancouver,
              groupValue: state.city,
              onChanged: (_) => changeCity(City.vancouver),
              child: Text(AppLocalizations.of(context)!.vancouver),
            ),
          ],
        );
      },
    );
  }
}
