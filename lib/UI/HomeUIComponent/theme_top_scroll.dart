import 'package:flutter/material.dart';

class TopScroll extends StatefulWidget {
  @override
  _TopScrollState createState() => _TopScrollState();
}

class _TopScrollState extends State<TopScroll> {
  @override
  Widget build(BuildContext context) => _topScroll(context);
}

Widget _topScroll(BuildContext context) {
  return Container(
    height: 40,
    padding: EdgeInsets.symmetric(vertical: 20),
    child: ListView(
      scrollDirection: Axis.horizontal,
      children: [
        topScrollElement(context, "Depression", selected: true),
        topScrollElement(context, "Sexual Condition"),
        topScrollElement(context, "Food & Diet"),
        topScrollElement(context, "Weight Loss & Obesity"),
        topScrollElement(context, "Oral Cancer"),
        topScrollElement(context, "Lonliness"),
        topScrollElement(context, "Anxiety")
      ],
    ),
  );
}

Widget topScrollElement(BuildContext context, String text,
    {bool selected = false, void Function() onTap}) {
  return Container(
    height: 30,
    padding: EdgeInsets.only(right: 10, left: 10),
    child: GestureDetector(
      onTap: onTap ?? () {},
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            text,
            style: Theme.of(context).textTheme.bodyText2.copyWith(
                fontWeight: FontWeight.w700,
                color: selected
                    ? Colors.deepPurpleAccent
                    : Theme.of(context).textTheme.bodyText2.color),
          ),
          SizedBox(height: 10),
          selected
              ? Container(
                  height: 5,
                  width: 20,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Colors.deepPurpleAccent,
                  ),
                )
              : Container()
        ],
      ),
    ),
  );
}
