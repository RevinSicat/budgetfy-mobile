import 'package:flutter/material.dart';

class AddAccountCard extends StatelessWidget{
    final VoidCallback onTap;
    const AddAccountCard({
        super.key,
        required this.onTap
    });

    @override
    Widget build(BuildContext context) {
        return GestureDetector(
            onTap: onTap,
            child: Container(
                width: 120,
                margin: const EdgeInsets.only(right: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(
                        color: Colors.grey, 
                        width: 2
                    ),
                    borderRadius: BorderRadius.circular(12)
                ),
                child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(
                            Icons.add,
                            color: Colors.grey
                        ),
                        SizedBox(height: 8),
                        Text(
                            'Add Account',
                            style: TextStyle(color: Colors.grey),
                        )
                    ],
                ),
            ),
        );
    }
}