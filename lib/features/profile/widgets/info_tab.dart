import 'package:flutter/material.dart';
import 'package:ppeso_mobile/core/styles.dart';
import 'package:ppeso_mobile/shared/content.dart';

class InfoTab extends StatefulWidget {
  const InfoTab({super.key});

  @override
  State<InfoTab> createState() => _InfoTabState();
}

class _InfoTabState extends State<InfoTab> {
  final TextEditingController _controller = TextEditingController();

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      _controller.text = "${picked.day}/${picked.month}/${picked.year}";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appBackground,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    margin: const EdgeInsets.all(30),
                    color: AppColors.widgetBackground,
                    child: Padding(
                      padding: const EdgeInsets.all(40.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            ProfilePageText.profileTile,
                            style: AppTextStyles.title,
                          ),
                          const SizedBox(height: 20),
                          //Nome Field
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: UserTextFields.name,
                              enabledBorder: TextInputStyles.enabledDefault,
                              focusedBorder: TextInputStyles.focusDefault,
                            ),
                          ),
                          const SizedBox(height: 15),
                          //Email Field
                          TextFormField(
                            decoration: InputDecoration(
                              labelText: UserTextFields.email,
                              enabledBorder: TextInputStyles.enabledDefault,
                              focusedBorder: TextInputStyles.focusDefault,
                            ),
                          ),
                          const SizedBox(height: 15),
                          //Password Field
                          TextFormField(
                            obscureText: true,
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
                            controller: _controller,
                            decoration: InputDecoration(
                              labelText: UserTextFields.birthday,
                              enabledBorder: TextInputStyles.enabledDefault,
                              focusedBorder: TextInputStyles.focusDefault,
                            ),
                            onTap: _selectDate,
                          ),
                          const SizedBox(height: 15),
                          //Height Field
                          TextFormField(
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              labelText: UserTextFields.height,
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
                      ),
                    ),
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
