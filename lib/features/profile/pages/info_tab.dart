import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/providers/user_provider.dart';
import 'package:ppeso_mobile/shared/content.dart';
import 'package:ppeso_mobile/shared/tab_structure.dart';

class InfoTab extends ConsumerStatefulWidget {
  const InfoTab({super.key});

  @override
  ConsumerState<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends ConsumerState<InfoTab> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();

    final user = ref.read(userProvider);
    if (user != null) {
      DateTime birthday = DateTime.parse(user['aniversario']);
      _controller = TextEditingController(
        text: "${birthday.day}/${birthday.month}/${birthday.year}",
      );
    } else {
      _controller = TextEditingController();
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      _controller.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProvider);

    return TabStructure(
      children: [
        Text(ProfilePageText.profileTile, style: AppTextStyles.title),
        const SizedBox(height: 20),
        //Nome Field
        TextFormField(
          initialValue: "${user?['nome']} ${user?['sobrenome']}",
          enabled: false,
          decoration: InputDecoration(
            labelText: UserTextFields.name,
            enabledBorder: TextInputStyles.enabledDefault,
            focusedBorder: TextInputStyles.focusDefault,
          ),
        ),
        const SizedBox(height: 15),
        //Email Field
        TextFormField(
          initialValue: user?['email'],
          enabled: false,
          decoration: InputDecoration(
            labelText: UserTextFields.email,
            enabledBorder: TextInputStyles.enabledDefault,
            focusedBorder: TextInputStyles.focusDefault,
          ),
        ),
        const SizedBox(height: 15),
        //Password Field
        TextFormField(
          initialValue: "user.password",
          obscureText: true,
          enabled: false,
          decoration: InputDecoration(
            labelText: UserTextFields.password,
            enabledBorder: TextInputStyles.enabledDefault,
            focusedBorder: TextInputStyles.focusDefault,
          ),
        ),
        const SizedBox(height: 15),
        //Birthday Field
        TextFormField(
          readOnly: true,
          enabled: false,
          controller: _controller,
          decoration: InputDecoration(
            labelText: UserTextFields.birthday,
            enabledBorder: TextInputStyles.enabledDefault,
            focusedBorder: TextInputStyles.focusDefault,
            suffixIcon: Icon(Icons.calendar_month, color: AppColors.primary),
          ),
          onTap: _selectDate,
        ),
        const SizedBox(height: 15),
        //Height Field
        TextFormField(
          keyboardType: TextInputType.number,
          initialValue:  user?['altura'].toString(),
          decoration: InputDecoration(
            labelText: UserTextFields.height,
            enabledBorder: TextInputStyles.enabledDefault,
            focusedBorder: TextInputStyles.focusDefault,
          ),
        ),
        const SizedBox(height: 15),
        //Starting Weight Field
        TextFormField(
          keyboardType: TextInputType.number,
          initialValue:  user?['peso_init'].toString(),
          enabled: false,
          decoration: InputDecoration(
            labelText: UserTextFields.initWeigth,
            enabledBorder: TextInputStyles.enabledDefault,
            focusedBorder: TextInputStyles.focusDefault,
          ),
        ),
        const SizedBox(height: 15),
        //Current Weight Field
        TextFormField(
          keyboardType: TextInputType.number,
          initialValue:  user?['peso_now'].toString(),
          enabled: false,
          decoration: InputDecoration(
            labelText: UserTextFields.nowWeigth,
            enabledBorder: TextInputStyles.enabledDefault,
            focusedBorder: TextInputStyles.focusDefault,
          ),
        ),
        const SizedBox(height: 15),
        //Target Weight Field
        TextFormField(
          keyboardType: TextInputType.number,
          initialValue:  user?['peso_target'].toString(),
          decoration: InputDecoration(
            labelText: UserTextFields.targetWeigth,
            enabledBorder: TextInputStyles.enabledDefault,
            focusedBorder: TextInputStyles.focusDefault,
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            ElevatedButton(
              onPressed: () {},
              style: ButtonStyles.defaultAcceptButton,
              child: const Text(ProfilePageText.updateButton),
            ),
            ElevatedButton(
              onPressed: () {
                // Handle login logic here
              },
              child: const Text(ProfilePageText.clearButton),
            ),
          ],
        ),
      ],
    );
  }
}
