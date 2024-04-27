import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:noteapp/layout/bottomScreens/archive.dart';
import 'package:noteapp/layout/bottomScreens/tasks.dart';
import 'package:noteapp/shared/cubit/cubit.dart';
import 'package:noteapp/shared/cubit/states.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite/sqlite_api.dart';

import 'bottomScreens/done.dart';
import 'constance.dart';

class MyHomePage extends StatelessWidget {


  var Scaffoldkey = GlobalKey<ScaffoldState>();
  var Formkey = GlobalKey<FormState>();
  var Taskcontrl = TextEditingController();
  var Timecontrl = TextEditingController();
  var Datecontrl = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (BuildContext context) =>AppCubit()..CreateDB(),
      child: BlocConsumer<AppCubit,AppStates>(
        listener: (BuildContext context, Object? state)
        {
          if(state is AppInsertToDBState)
          {
            Navigator.pop(context);
          }
        },
        builder: (BuildContext context, state)
        {

          AppCubit Cubit = AppCubit.get(context);

          return Scaffold(
            key: Scaffoldkey,
            appBar: AppBar(title: Text(Cubit.bottomtitle[Cubit.CurrentInd]),),
            floatingActionButton: FloatingActionButton(
              onPressed: () {
                if(Cubit.isBottomsheetshow){
                  if(Formkey.currentState!.validate()){
                    Cubit.insertDB(task: Taskcontrl.text, time: Timecontrl.text, date: Datecontrl.text,);
                    // InsertDB(
                    //   task: Taskcontrl.text,
                    //   time: Timecontrl.text,
                    //   date: Datecontrl.text,
                    // ).then((value) {
                    //   Navigator.pop(context);
                    //   isBottomsheetshow = false ;
                    //   // setState(() {
                    //   //   fabicon = Icons.edit ;
                    //   // });
                    // });
                  }
                }
                else{
                  Scaffoldkey.currentState!.showBottomSheet(
                      elevation: 15.0,
                          (context) => Container(
                        padding: const EdgeInsets.all(30),
                        color: Colors.white,
                        child: Form(
                          key: Formkey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: Taskcontrl,
                                keyboardType: TextInputType.name,
                                validator: (value){
                                  if(value!.isEmpty){
                                    return 'The Form Cant be empty';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Task Title',
                                  prefixIcon: const Icon(Icons.task),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                              const SizedBox(height: 12,),
                              TextFormField(
                                controller: Timecontrl,
                                keyboardType: TextInputType.datetime,
                                onTap: (){
                                  showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                  ).then(
                                          (value) => Timecontrl.text = value!.format(context).toString());
                                },
                                //enabled: false,
                                validator: (value){
                                  if(value!.isEmpty){
                                    return 'The Form Cant be empty';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Task Time',
                                  prefixIcon: const Icon(Icons.watch_later_outlined),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                              const SizedBox(height: 12,),
                              TextFormField(
                                controller: Datecontrl,
                                onTap: (){
                                  showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now(),
                                    lastDate: DateTime.parse('2030-05-03'),
                                  ).then(
                                          (value) {
                                        Datecontrl.text = DateFormat.yMMMd().format(value!);
                                      }
                                  );
                                },
                                //enabled: false,
                                validator: (value){
                                  if(value!.isEmpty){
                                    return 'The Form Cant be empty';
                                  }
                                  return null;
                                },
                                decoration: InputDecoration(
                                  labelText: 'Date Time',
                                  prefixIcon: const Icon(Icons.date_range),
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                  ).closed.then((value) {
                    Cubit.ChangeBottomSheetState(isShow: false, icon: Icons.edit);
                  });
                  Cubit.ChangeBottomSheetState(isShow: true, icon: Icons.add);
                }
              },
              child: Icon(Cubit.fabicon),
            ),
            bottomNavigationBar: BottomNavigationBar(
              type:BottomNavigationBarType.fixed,
              currentIndex: Cubit.CurrentInd,
              onTap: (index){
                Cubit.ChangeIndex(index);
              },
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.task),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.done_outline_rounded),
                  label: 'Done',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.archive),
                  label: 'Archive',
                ),
              ],
            ),
            body: ConditionalBuilder(
                condition: state is! AppGetFromDBLoadingState,
                builder: (context) => Cubit.screens[Cubit.CurrentInd],
                fallback: (context) => const Center(child: CircularProgressIndicator()),
            ),
          );
        },
      ),
    );
  }
}
