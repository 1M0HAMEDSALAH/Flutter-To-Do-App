import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../shared/cubit/cubit.dart';
import '../../shared/cubit/states.dart';

class Done extends StatelessWidget {
  const Done({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppCubit,AppStates>(
      listener: (BuildContext context, AppStates state) {  },
      builder: (BuildContext context, AppStates state)
      {
        var tasks = AppCubit.get(context).DoneTasksdata;
        return ConditionalBuilder(
          condition: tasks.length > 0,
          builder: (BuildContext context) =>ListView.separated(
            itemBuilder: (context,index){
              return Dismissible(
                onDismissed: (direction){
                  AppCubit.get(context).Deletedb(id: tasks[index]['id']);
                },
                key: Key(tasks[index]['id'].toString()),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        child: Text('${tasks[index]['time']}'),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${tasks[index]['title']}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${tasks[index]['date']}',
                              style: const TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      IconButton(
                        onPressed: (){
                          AppCubit.get(context).Updatedb(status: 'done', id: tasks[index]['id']);
                        },
                        icon: Icon(Icons.done_outlined,color: Colors.cyan,),
                      ),
                      IconButton(
                        onPressed: (){
                          AppCubit.get(context).Updatedb(status: 'archive', id: tasks[index]['id']);
                        },
                        icon: Icon(Icons.archive,color: Colors.grey,),
                      ),
                    ],
                  ),
                ),
              );
            },
            separatorBuilder: (context,index){
              return Container(
                height: 1.0,
                width: double.infinity,
                color: Colors.grey[300],
              );
            },
            itemCount: tasks.length,
          ),
          fallback: (BuildContext context) => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.hourglass_empty,size: 100,color: Colors.grey,),
                Text('Sorry The ${AppCubit.get(context).bottomtitle[AppCubit.get(context).CurrentInd]} Screen is Empty :)')
              ],
            ),
          ),
        );
      },
    );
  }
}
