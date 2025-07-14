import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sugapulse/theme.dart';

class ReusableCard extends StatelessWidget {
  const ReusableCard({
    required this.op,
    required this.icon,
    required this.title,
    super.key,
  });
  final String title;
  final IconData icon;
  final Function()? op;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: op,
        child: Container(
          height: 120,
          decoration: BoxDecoration(
            color: Provider.of<myTheme>(context).theme
                ? Colors.purple
                : Colors.greenAccent,
            borderRadius: BorderRadius.all(Radius.circular(30)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(icon,
                  size: 50,
                  color: Provider.of<myTheme>(context).theme
                      ? Colors.white
                      : Colors.black),
              Text(
                title,
                style: TextStyle(
                    color: Provider.of<myTheme>(context).theme
                        ? Colors.white
                        : Colors.black),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
