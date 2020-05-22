import 'dart:developer';

import 'package:flutter/material.dart';

import '../../../configs/AppColors.dart';

class SearchBar extends StatelessWidget {
  SearchBar({
    Key key,
    EdgeInsets margin = const EdgeInsets.symmetric(horizontal: 28),
    Function(String find) onSubmit,
  }) : super(key: key) {
    this.onSubmit = onSubmit;
    this.margin = margin;
  }

  EdgeInsets margin;
  Function(String find) onSubmit;
  String val = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 18),
      margin: margin,
      decoration: ShapeDecoration(
        shape: StadiumBorder(),
        color: Theme.of(context).scaffoldBackgroundColor,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.search),
          SizedBox(width: 13),
          Expanded(
            child: TextFormField(
              // onChanged: (x) {
              //   log(x);
              //   val = x;
              // },
              onFieldSubmitted: (x) {
                onSubmit(x);
              },
              decoration: InputDecoration(
                hintText: "Search Pokemon, Move, Ability etc",
                hintStyle: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
