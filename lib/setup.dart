import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:food_traker/src/backend/first_start_setup.dart';
import 'package:food_traker/src/backend/types/activity_level.dart';
import 'package:food_traker/src/backend/types/exceptions/insane_value.dart';
import 'package:food_traker/src/backend/types/gender.dart';
import 'package:food_traker/src/backend/user_data.dart';
import 'package:food_traker/src/dashboard/dashboard.dart';
import 'package:food_traker/src/utils.dart';
import 'package:intl/intl.dart';

class Setup extends StatefulWidget {
  const Setup({super.key});

  @override
  State<Setup> createState() => _SetupState();
}

class _SetupState extends State<Setup> {
  final PageController _controllerGetStarted = PageController();
  final PageController _controllerInformationConfiguration = PageController();
  final TextEditingController _controllerName = TextEditingController();
  final TextEditingController _controllerHeight = TextEditingController();
  DateTime? _controllerAge;
  Gender? _controllerGender;
  ActivityLevel? _controllerActivityLevel;
  final TextEditingController _controllerWeight = TextEditingController();
  bool isSaving = false;

  Future<void> showDialogNameNotSet() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Name not set'),
          content: const Text('Please set your name to continue.'),
          actions: <Widget>[
            FilledButton(
              child: const Text('Ok'),
              onPressed: () {
                Utils.pop(context: context, currentRouteName: 'setup');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showDialogHeightNotSet() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Height not set'),
          content: const Text('Please set your height to continue.'),
          actions: <Widget>[
            FilledButton(
              child: const Text('Ok'),
              onPressed: () {
                Utils.pop(context: context, currentRouteName: 'setup');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showDialogBirthNotSet() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Birthday not set'),
          content: const Text('Please set your birthday to continue.'),
          actions: <Widget>[
            FilledButton(
              child: const Text('Ok'),
              onPressed: () {
                Utils.pop(context: context, currentRouteName: 'setup');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showDialogGenderNotSet() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Gender not set'),
          content: const Text('Please set your gender to continue.'),
          actions: <Widget>[
            FilledButton(
              child: const Text('Ok'),
              onPressed: () {
                Utils.pop(context: context, currentRouteName: 'setup');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showDialogWeightNotSet() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Weight not set'),
          content: const Text('Please set your weight to continue.'),
          actions: <Widget>[
            FilledButton(
              child: const Text('Ok'),
              onPressed: () {
                Utils.pop(context: context, currentRouteName: 'setup');
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> showDialogActivityLevelNotSet() async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Activity level not set'),
          content: const Text('Please set your activity level to continue.'),
          actions: <Widget>[
            FilledButton(
              child: const Text('Ok'),
              onPressed: () {
                Utils.pop(context: context, currentRouteName: 'setup');
              },
            ),
          ],
        );
      },
    );
  }


  /// Returns a Row widget containing a back button and a next button for navigation between pages.
  /// 
  /// This widget is utilized within the setup screens to navigate between different setup steps.
  /// The `back` button allows users to go back to the previous page, while the `next` button
  /// validates the current page's data and, upon successful validation, navigates to the next page.
  /// 
  /// Parameters:
  /// - `nextPageId`: An integer representing the id of the next page to navigate to. Special handling
  ///   is done if `nextPageId` is 1, as it determines which `PageController` to use for navigating backwards.
  /// - `onPressed`: A callback function that is executed when the `next` button is pressed. This function
  ///   should return a `Future<bool>` indicating whether the navigation to the next page should proceed
  ///   based on the validation of the current page's data.
  ///   - Returns `true` if the navigation should proceed.
  ///   - Returns `false` if the navigation should be blocked (usually due to invalid or missing information).
  /// 
  /// Usage:
  /// This function is typically used within the setup screens to navigate through different configuration
  /// steps, such as setting up the user's name, age, gender, height, weight, and activity level.
  /// 
  /// Example:
  /// ```dart
  /// buttonsBackNext(2, () async {
  ///   if (_controllerName.text.isEmpty) {
  ///     await showDialogNameNotSet();
  ///     return false;
  ///   } else {
  ///     await UserData.setName(_controllerName.text);
  ///     return true;
  ///   }
  /// })
  /// ```
  /// 
  /// In this example, `nextPageId` is set to 2, meaning the next page is the second page. The `onPressed`
  /// callback function validates the user's name and proceeds to the next page only if the name is not empty.
  Widget buttonsBackNext(int nextPageId, Future<bool> Function() onPressed) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: 35,
          child: IconButton.filled(
              onPressed: () {
                if (!isSaving) {
                  if (nextPageId == 1) {
                    _controllerGetStarted.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  } else {
                    _controllerInformationConfiguration.previousPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.easeInOut);
                  }
                }
              },
              icon: isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(
                      Icons.arrow_back,
                      size: 12,
                    )),
        ),
        const SizedBox(width: 8),
        FilledButton(
            onPressed: () async {
              if (isSaving) return;
              isSaving = true;
              setState(() {});
              bool result = await onPressed();
              isSaving = false;
              setState(() {});
              if (result) {
                if (nextPageId == 6) {
                  await FirstStartSetup.init();
                  if (mounted) {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const Dashboard(),
                      ),
                      (Route<dynamic> route) => false,
                    );
                  }
                }
                _controllerInformationConfiguration.animateToPage(nextPageId,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeInOut);
              }
            },
            child: const Text(
              'Next',
            )),
        if (nextPageId != 1) const SizedBox(width: 40),
      ],
    );
  }

  @override
  void setState(VoidCallback fn) {
    if (mounted) super.setState(fn);
  }

  @override
  void initState() {
    _controllerName.text = UserData.name ?? '';
    _controllerHeight.text = UserData.height?.toString() ?? '';
    _controllerAge = UserData.birthday;
    _controllerGender = UserData.gender;
    _controllerWeight.text = UserData.weight?.toString() ?? '';
    _controllerActivityLevel = UserData.activityLevel;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: PageView(
            controller: _controllerGetStarted,
            physics: const NeverScrollableScrollPhysics(),
            children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Welcome to the app!',
                  style: TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
              const SizedBox(height: 80),
              const Text(
                "Track your daily intake of food and stay healthy!",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 80),
              FilledButton(
                onPressed: () {
                  _controllerGetStarted.animateToPage(1,
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeInOut);
                },
                child: const Text(
                  'Get Started',
                ),
              ),
              const SizedBox(height: 40),
              TextButton(
                onPressed: () async {
                  await Utils.importBackup();
                  await UserData.init();
                  firstStart = UserData.firstStart;
                  if (!(firstStart ?? true)) {
                    if (context.mounted) {
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (context) => const Dashboard(),
                        ),
                        (Route<dynamic> route) => false,
                      );
                    }
                  }
                },
                child: const Text(
                  'Import Backup',
                ),
              ),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Let\'s set up some\ninformation about you',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 70),
              SizedBox(
                height: 300,
                child: PageView(
                  controller: _controllerInformationConfiguration,
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    Column(
                      children: [
                        const Text('What is your name?',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 200,
                          child: TextField(
                              maxLength: 100,
                              controller: _controllerName,
                              decoration: const InputDecoration(
                                  labelText: 'Name',
                                  counterText: '',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.person))),
                        ),
                        const SizedBox(height: 80),
                        buttonsBackNext(1, () async {
                          if (_controllerName.text.isEmpty) {
                            await showDialogNameNotSet();
                            return false;
                          } else {
                            await UserData.setName(_controllerName.text);
                            return true;
                          }
                        })
                      ],
                    ),
                    Column(
                      children: [
                        const Text('What is your birthday?',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        FilledButton(
                          onPressed: () async {
                            final DateTime? picked = await showDatePicker(
                                context: context,
                                initialDate: _controllerAge,
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now());
                            if (picked != null && picked != _controllerAge) {
                              setState(() {
                                _controllerAge = picked;
                              });
                            }
                          },
                          child: Text(
                            _controllerAge == null
                                ? "Click to set a date"
                                : DateFormat('dd/MM/yyyy')
                                    .format(_controllerAge!),
                          ),
                        ),
                        const SizedBox(height: 80),
                        buttonsBackNext(2, () async {
                          if (_controllerAge == null) {
                            await showDialogBirthNotSet();
                            return false;
                          } else {
                            await UserData.setBirthday(_controllerAge!);
                            return true;
                          }
                        })
                      ],
                    ),
                    Column(
                      children: [
                        const Text('What is your gender?',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Card(
                          child: SizedBox(
                            width: 200,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                RadioListTile<Gender?>(
                                  value: _controllerGender,
                                  groupValue: Gender.male,
                                  onChanged: (Gender? value) {
                                    setState(() {
                                      _controllerGender = Gender.male;
                                    });
                                  },
                                  title: const Text('Male'),
                                ),
                                RadioListTile<Gender?>(
                                  value: _controllerGender,
                                  groupValue: Gender.female,
                                  onChanged: (Gender? value) {
                                    setState(() {
                                      _controllerGender = Gender.female;
                                    });
                                  },
                                  title: const Text('Female'),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 80),
                        buttonsBackNext(3, () async {
                          if (_controllerGender == null) {
                            await showDialogGenderNotSet();
                            return false;
                          } else {
                            await UserData.setGender(_controllerGender!);
                            return true;
                          }
                        })
                      ],
                    ),
                    Column(
                      children: [
                        const Text('What is your height?',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 200,
                          child: TextField(
                              controller: _controllerHeight,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.deny(
                                    RegExp(r'[^\d]')),
                              ],
                              decoration: const InputDecoration(
                                  labelText: 'Height (cm)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.height))),
                        ),
                        const SizedBox(height: 80),
                        buttonsBackNext(4, () async {
                          if (_controllerHeight.text.isEmpty) {
                            await showDialogHeightNotSet();
                            return false;
                          } else {
                            try {
                              await UserData.setHeight(
                                  int.parse(_controllerHeight.text));
                              return true;
                            } on InsaneValueException {
                              if (context.mounted) {
                                await Utils.showDialogNotValidValue(context);
                              }
                              return false;
                            }
                          }
                        })
                      ],
                    ),
                    Column(
                      children: [
                        const Text('What is your weight?',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: 200,
                          child: TextField(
                              controller: _controllerWeight,
                              keyboardType: TextInputType.number,
                              inputFormatters:
                                  CustomTextInputFormatter.doubleOnly(),
                              decoration: const InputDecoration(
                                  labelText: 'Weight (kg)',
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.scale))),
                        ),
                        const SizedBox(height: 80),
                        buttonsBackNext(5, () async {
                          if (_controllerWeight.text.isEmpty) {
                            await showDialogWeightNotSet();
                            return false;
                          } else {
                            try {
                              await UserData.setWeight(
                                  double.parse(_controllerWeight.text));
                              return true;
                            } on InsaneValueException {
                              if (context.mounted) {
                                await Utils.showDialogNotValidValue(context);
                              }
                              return false;
                            }
                          }
                        })
                      ],
                    ),
                    Column(
                      children: [
                        const Text('What is your activity level?',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        DropdownButton<ActivityLevel>(
                          value: _controllerActivityLevel,
                          onChanged: (ActivityLevel? value) {
                            setState(() {
                              _controllerActivityLevel = value;
                            });
                          },
                          hint: const Text('Select your activity level'),
                          items:
                              ActivityLevel.values.map((ActivityLevel value) {
                            return DropdownMenuItem<ActivityLevel>(
                              value: value,
                              child: Text(value.value),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 80),
                        buttonsBackNext(6, () async {
                          if (_controllerActivityLevel == null) {
                            await showDialogActivityLevelNotSet();
                            return false;
                          } else {
                            await UserData.setActivityLevel(
                                _controllerActivityLevel!);
                            return true;
                          }
                        })
                      ],
                    )
                  ],
                ),
              ),
            ],
          )
        ]));
  }
}
