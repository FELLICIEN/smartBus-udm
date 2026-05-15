

import 'package:flutter/material.dart';

class BusProgrammer extends StatefulWidget {
  const BusProgrammer({super.key});

  @override
  State<BusProgrammer> createState() => _BusProgrammerState();
}

TextEditingController busSelected = TextEditingController();
TextEditingController stationSelected = TextEditingController();
TextEditingController heureSelected = TextEditingController();

String busSel = '';
class _BusProgrammerState extends State<BusProgrammer> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
         title: Text("Programmer un bus"),
         backgroundColor: Theme.of(context).primaryColor,
      ),
      body: Container(
        
        margin: EdgeInsets.all(10),
        child: Column(
          children: [
            Icon(Icons.bus_alert_outlined,size: 400,),
            Center(
              
              child: SingleChildScrollView(
                
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(10),
                child: Container(
                  padding: EdgeInsets.all(10),
                  color: Colors.green,
                  
                  child: Column(
                    children: [
                      Container(
                        margin: EdgeInsets.all(15),
                        child: DropdownButtonFormField(
                          
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: [
                         DropdownMenuItem(
                          value: 'bus1',
                          child: Text("Bus 1")),
                        
                          DropdownMenuItem(
                          value: 'bus2',
                          child: Text("Bus 2")),
                        
                          DropdownMenuItem(
                          value: 'bus3',
                          child: Text("Bus 3")),
                          
                           
                        
                          
                          ], 
                          
                          
                          onChanged:(String ? value){
                            setState(() {
                              busSel=value!   ;
                            });
                          }),
                      ),
                  
                  
                        Container(
                        margin: EdgeInsets.all(15),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: [
                         DropdownMenuItem(
                          value: 'stat1',
                          child: Text(" Station 1")),
                        
                          DropdownMenuItem(
                          value: 'stat2',
                          child: Text(" Station 2")),
                        
                          DropdownMenuItem(
                          value: 'bus3',
                          child: Text("Station 3")),
                          
                           
                        
                          
                          ], 
                          
                          
                          onChanged:(String ? value){
                            setState(() {
                              busSel=value!   ;
                            });
                          }),
                      ),
                  
                  
                        Container(
                        margin: EdgeInsets.all(15),
                        child: DropdownButtonFormField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                          ),
                          items: [
                         DropdownMenuItem(
                          value: '1',
                          child: Text("05:00")),
                        
                          DropdownMenuItem(
                          value: '2',
                          child: Text("05:30")),
                        
                          DropdownMenuItem(
                          value: '3',
                          child: Text("06:00)")),
                      
                          ], 
                          
                          
                          onChanged:(String ? value){
                            setState(() {
                              busSel=value!   ;
                              
                            });
                            
                          }
                          
                          ),
                          
                          
                      ),
                      ElevatedButton(
                    
                          onPressed: (){
                            (value) {
                            if(busSel==""){
                              return setState(() {
                                 Text( "veuillez selectionner un bus ");
                              });
                            }
                          };
                          },
                           child: Text("Programmer un bus ")),
                      
                        
                    ],
                  ),
                ),
              ),
              ),
            ),
          ],
        ),
      ),
    );

  }
}