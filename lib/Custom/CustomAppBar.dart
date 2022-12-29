import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {

  final  List<IconButton> empty = [];
  final String title;
  final String subtitle;
  final List<IconButton> actions;

  double heightWithSub = 113;
  double heightWithoutSub = 90;
  CustomAppBar({required this.title, this.subtitle="", this.actions = const []});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (BuildContext context) {
            if (Navigator.of(context).canPop()) {
              return Container(
                child: IconButton(alignment: Alignment.topCenter,
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  tooltip: MaterialLocalizations.of(context).openAppDrawerTooltip,
                ),
              );
            }
            else{
              return Container();
            }
          },
        ),
        toolbarHeight: subtitle!=""?heightWithSub:heightWithoutSub,
        flexibleSpace: Container(
          padding: EdgeInsets.only(top:15, bottom: 15, left: 20),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  title,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                if(subtitle!="")
                Text(
                  subtitle,
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                )
              ]),
        ),
        actions: actions,
      );
  }
  
  @override
  // TODO: implement preferredSize
  Size get preferredSize => Size.fromHeight(subtitle!=""?heightWithSub:heightWithoutSub);
}