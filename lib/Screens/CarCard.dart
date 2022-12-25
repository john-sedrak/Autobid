import 'Car.dart';
import 'package:flutter/material.dart';

class CarCard extends StatefulWidget{

  Car car;

  CarCard({required this.car});

  @override
  State<CarCard> createState() => _CarCardState();
}

class _CarCardState extends State<CarCard> {

  bool isFav = false;

  @override
  void initState() {
    super.initState();
  }

  void goToBiddingScreen(BuildContext context){
      Navigator.of(context).pushNamed('/bidRoute', arguments: {'car': widget.car});
  } 

  @override
  Widget build(BuildContext context){

    

    return InkWell(
      onTap: () => goToBiddingScreen(context),
      child: Container( height: 380,
        child: Card(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          elevation: 4,
          margin: EdgeInsets.all(10),
          child: Column(children: [
            Stack(
              children: [
                ClipRRect(borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(15),
                  topRight: Radius.circular(15)),
                  child: Image.network(widget.car.carImagePaths[0], height: 250, width: double.infinity, fit: BoxFit.cover)
                ),
                // Positioned.fill(bottom: 0,child: ClipRRect(
                //   borderRadius: const BorderRadius.only(
                //   topLeft: Radius.circular(15),
                //   topRight: Radius.circular(15)),
                //   child: Container(
                //     color: Colors.black38,
                //     child: Center(child: Text(
                //       widget.car.brand + " " + widget.car.model + " " + widget.car.year.toString(), 
                //       softWrap: true, 
                //       overflow: TextOverflow.fade, 
                //       style: const TextStyle(color: Colors.white, fontSize: 30),
                //       textAlign: TextAlign.center,
                //     ))
                //   )))
                ]),
                  Container(
                    margin: EdgeInsets.all(10),
                    padding: EdgeInsets.all(15),
                    child: ListTile(
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.blue,
                        child: Column(mainAxisAlignment: MainAxisAlignment.center),
                      ),
                      title: Text(widget.car.brand + " " + widget.car.model + " " + widget.car.year.toString(), style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                      //subtitle: Row(children: [Icon(Icons.calendar_month), Text(DateFormat('dd-MM-yyyy').format(ex.date), style: const TextStyle(color: Colors.grey))]),
                      trailing: IconButton(onPressed: (){setState(() {
                                                  isFav = !isFav;
                      });}, icon: Icon(isFav?Icons.star:Icons.star_border, color: Colors.yellow)),
                    )
                    // child: Row(
                    //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                    //   children: [

                    //     
                    //   ]
                    // ,)
                    )
                ])
              
            ),
      )
        );
      
  }
}