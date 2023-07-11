import 'package:flutter/material.dart';
import 'package:flutter_isar_db/collections/Category.dart';
import 'package:flutter_isar_db/collections/routine.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:timeago/timeago.dart' as timeago;

//Global Isar Instance
late Isar isarDatabase;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  //Initializing the Isar Database
  final dir = await getApplicationSupportDirectory();
  isarDatabase = await Isar.open(
    [RoutineSchema, CategorySchema],
    directory: dir.path,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
  });

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(
        title: 'Flutter Isar DB',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final textController = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<List<Routine>> getAllRoutines() async {
    var data =
        await isarDatabase.routines.where().sortByStartTimeDesc().findAll();
    debugPrint("IsarData: ${data.first.title}");
    return data;
  }

  void addTitle() async {
    var text = textController.value.text.toString().trim();
    if (text.isNotEmpty) {
      // final newCategory = Category()..name = "Test Category";

      final newRoutine = Routine()
        ..title = text
        ..day = "Monday"
        ..startTime = DateTime.now();

      await isarDatabase.writeTxn(() async {
        //  await widget.isar.categorys.put(newCategory);
        // await isar.users.put(newUser); // insert & update
        await isarDatabase.routines.put(newRoutine);
        await getAllRoutines();
      });
      textController.clear();
      setState(() {});
    }
  }

  Future<void> deleteTitle({required int id}) async {
    await isarDatabase.writeTxn(() async {
      await isarDatabase.routines.delete(id);
    });

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextFormField(
              controller: textController,
              decoration: const InputDecoration(
                hintText: "Title",
              ),
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          Expanded(
            child: FutureBuilder(
              future: getAllRoutines(),
              builder: (BuildContext context,
                  AsyncSnapshot<List<Routine>> snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text(snapshot.error.toString()));
                }
                // WHILE THE CALL IS BEING MADE AKA LOADING
                if (!snapshot.hasData) {
                  return const Center(child: Text('Loading'));
                }

                // IF IT WORKS IT GOES HERE!
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var data = snapshot.data![index];
                    return Dismissible(
                      key: UniqueKey(),
                      background: Container(
                        color: Colors.red,
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) async {
                        await deleteTitle(id: data.id);
                        // Scaffold
                        //     .of(context)
                        //     .showSnackBar(SnackBar(content: Text("$item dismissed")));
                      },
                      child: Card(
                        child: ListTile(
                          leading: Text(
                            data.id.toString(),
                            //style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          onTap: () {},
                          title: Text(
                            data.title,
                            //style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          subtitle: Text(
                            data.day,
                            //style: Theme.of(context).textTheme.headlineSmall,
                          ),
                          trailing: Text(
                            timeago.format(data.startTime, locale: "en_short"),
                            // style: Theme.of(context).textTheme.headlineMedium,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          addTitle();
        },
        tooltip: 'Add',
        child: const Icon(Icons.add),
      ),
    );
  }
}
