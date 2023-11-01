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
          menuChildren: City.values.map((city) {
            return RadioMenuButton<City>(
              value: city,
              groupValue: state.city,
              onChanged: (_) => changeCity(city),
              child: Text(AppLocalizations.of(context)!.getCity(city.name)),
            );
          }).toList(),
        );
      },
    );
  }
}
