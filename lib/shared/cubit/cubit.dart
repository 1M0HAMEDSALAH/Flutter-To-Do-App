import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:noteapp/shared/cubit/states.dart';
import 'package:sqflite/sqflite.dart';
import '../../layout/bottomScreens/archive.dart';
import '../../layout/bottomScreens/done.dart';
import '../../layout/bottomScreens/tasks.dart';


class AppCubit extends Cubit<AppStates>{
  AppCubit() : super(AppIntialState());
  static AppCubit get(context) => BlocProvider.of(context);

  int CurrentInd = 0 ;
  List<Widget> screens = [
    Tasks(),
    Done(),
    Archive(),
  ];
  List<String> bottomtitle = [
    'Tasks',
    'Done',
    'Archive',
  ];


  void ChangeIndex(index)
  {
    CurrentInd = index ;
    emit(AppChangeBottomNavState());
  }

  Database? db;
  List<Map> Tasksdata = [];
  List<Map> DoneTasksdata = [];
  List<Map> ArchiveTasksdata = [];

  void CreateDB()async {
    openDatabase(
        'tasks.db',
        version: 1,
        onCreate: (db,version){
          print('db is created');
          db
              .execute('CREATE TABLE tasks (id INTEGER PRIMARY KEY , title TEXT , date TEXT , time TEXT, status TEXT)')
              .then((value) => null)
              .catchError((e) => print(e.toString()) );
        },
        onOpen: (db){
          getData(db);
          emit(AppGetFromDBState());
          print('db is opened');
        }
    ).then((value) {
      db = value ;
      emit(AppCreateDBState());
    });
  }
  Future insertDB({
    required String task,
    required String time,
    required String date,
  }) async {
    await db?.transaction((txn) async {
        await txn.rawInsert(
            'INSERT INTO tasks(title, time, date, status) VALUES(?, ?, ?, "New")',
            [task, time, date]).then((value)
        {
          print('$value inserted successfully');
          emit(AppInsertToDBState());
          getData(db!).then((value) {
            if(value != null){
            Tasksdata = value;
            emit(AppGetFromDBState());
            }
          });
        }
        ).catchError((e)=>print('Error inserting data: $e'));
        print('DB is accessed');
    });
  }

  getData(Database db) async {
    Tasksdata = [];
    DoneTasksdata = [];
    ArchiveTasksdata = [];
    emit(AppGetFromDBLoadingState());
      await db.rawQuery('SELECT * FROM tasks')
          .then((value){
            value.forEach((element) {
              if(element['status'] == 'New'){
                Tasksdata.add(element);
              }else if(element['status'] == 'done'){
                DoneTasksdata.add(element);
              }else {ArchiveTasksdata.add(element);}
            });
            emit(AppGetFromDBState());
      }).catchError((e)=>print('Error fetching data: $e'));
  }

  Updatedb({
    required String status,
    required int id,
})async {
     db?.rawUpdate(
        'UPDATE tasks SET status =? WHERE id =?',
      ['$status', id]
    ).then((value) {
       getData(db!);
      emit(AppUpdateDBState());
     });
  }

  Deletedb({
    required int id,
})async {
     db?.rawDelete(
        'DELETE FROM tasks WHERE id =?',
      [id]
    ).then((value) {
       getData(db!);
      emit(AppDeleteDBState());
     });
  }

  bool isBottomsheetshow = false ;
  IconData fabicon = Icons.edit ;

  void ChangeBottomSheetState({
    required bool isShow,
    required IconData icon,
})
  {
    isBottomsheetshow = isShow;
    fabicon = icon;
    emit(AppChangeSheetState());
  }

}