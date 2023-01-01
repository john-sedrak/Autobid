import 'package:flutter/material.dart';
import 'package:steps_indicator/steps_indicator.dart';

class AddCarScreen extends StatefulWidget {
  const AddCarScreen({super.key});

  @override
  State<AddCarScreen> createState() => _AddCarScreenState();
}

class _AddCarScreenState extends State<AddCarScreen> {
  int _currentStep = 0;

  _stepState(int step) {
    if (_currentStep > step) {
      return StepState.complete;
    } else {
      return StepState.editing;
    }
  }

  _steps() => [
        Step(
          title: Text('Car Details'),
          content: _CarDetails(),
          state: _stepState(0),
          isActive: _currentStep == 0,
        ),
        Step(
          title: Text('Photos'),
          content: _UploadPhotos(),
          state: _stepState(1),
          isActive: _currentStep == 1,
        ),
      ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          iconTheme: IconThemeData(
            color: Colors.white,
          ),
          title: const Text(
            'Add a Car',
            style: TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.pink,
        ),
        body: SafeArea(
          child: Stepper(
            controlsBuilder: (BuildContext context, ControlsDetails controls) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Row(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: controls.onStepContinue,
                      child: const Text('NEXT'),
                    ),
                    if (_currentStep != 0)
                      TextButton(
                        onPressed: controls.onStepCancel,
                        child: const Text(
                          'BACK',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                  ],
                ),
              );
            },
            type: StepperType.horizontal,
            onStepTapped: (step) => setState(() => _currentStep = step),
            onStepContinue: () {
              setState(() {
                if (_currentStep < _steps().length - 1) {
                  _currentStep += 1;
                } else {
                  _currentStep = 0;
                }
              });
            },
            onStepCancel: () {
              setState(() {
                if (_currentStep > 0) {
                  _currentStep -= 1;
                } else {
                  _currentStep = 0;
                }
              });
            },
            currentStep: _currentStep,
            steps: _steps(),
          ),
        ));
  }
}

class _UploadPhotos extends StatelessWidget {
  const _UploadPhotos({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Street',
          ),
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'City',
          ),
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Postcode',
          ),
        ),
      ],
    );
  }
}

class _CarDetails extends StatelessWidget {
  const _CarDetails({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Card number',
          ),
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'Expiry date',
          ),
        ),
        TextFormField(
          decoration: const InputDecoration(
            labelText: 'CVV',
          ),
        ),
      ],
    );
  }
}

class _Overview extends StatelessWidget {
  const _Overview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Center(child: Text('Thank you for your order!')),
      ],
    );
  }
}
