import 'package:flutter/material.dart';
import 'package:manuals_hub/core/theme/app_colors.dart';

class HmCategory extends StatefulWidget {
  const HmCategory({super.key});

  @override
  State<HmCategory> createState() => _HmCategoryState();
}

class _HmCategoryState extends State<HmCategory> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 40,
      padding: const EdgeInsets.only(top: 10, left: 10, right: 10, bottom: 2),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 6,
        itemBuilder: (BuildContext context, int index) {
          return Container(
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              borderRadius: BorderRadius.circular(20),
            ),
            width: 90,
            // height: 40,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(right: 10),
            child: Text("品牌", style: TextStyle(color: Colors.white)),
          );
        },
      ),
    );
  }
}
