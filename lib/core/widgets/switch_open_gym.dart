import 'package:flutter/material.dart';

class OpenGymSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool> onChanged;

  const OpenGymSwitch({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
        switchTheme: SwitchThemeData(
          trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
        ),
      ),
      child: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: const Color(0xff0EA5E9),
        inactiveThumbColor: Colors.white,
        inactiveTrackColor: const Color(0xffD1D5DB),
      ),
    );
  }
}
