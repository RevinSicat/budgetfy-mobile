import 'package:flutter/material.dart';

class GreetingHeader extends StatelessWidget{
    const GreetingHeader({super.key});

    String getGreeting() {
        final hour = DateTime.now().hour;
        if (hour < 12) {
            return 'Good Morning!';
        } else if (hour < 17) {
            return 'Good Afternoon!';
        }
        return 'Good Evening!';
    }

    @override
    Widget build(BuildContext context) {
        return Text(
            getGreeting(),
            style: Theme.of(context)
                    .textTheme
                    .headlineLarge
        );
    }
}