import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class AboutCardWidget extends StatelessWidget {
  final String description;
  final String svgAssetPath;

  const AboutCardWidget({Key? key, required this.description, required this.svgAssetPath})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: () {},
        borderRadius: const BorderRadius.all(Radius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 16),
              SvgPicture.asset(
                svgAssetPath,
                width: MediaQuery.of(context).size.width / 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
