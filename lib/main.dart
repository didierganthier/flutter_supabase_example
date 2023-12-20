import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'secrets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: SUPABASE_URL,
    anonKey: SUPABASE_ANON_KEY,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _notesStream =
      Supabase.instance.client.from('notes').stream(primaryKey: ['id']);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Supabase Notes App',
        ),
      ),
      body: StreamBuilder(
        stream: _notesStream,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(
              child: Text('Error'),
            );
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final notes = snapshot.data as List<dynamic>;

          return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              final note = notes[index];

              return ListTile(
                title: Text(note['body'] as String),
                trailing: IconButton(
                  onPressed: () async {
                    await Supabase.instance.client
                        .from('notes')
                        .delete()
                        .eq('id', note['id'])
                        .then((value) => {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Note deleted'),
                                ),
                              )
                            });
                  },
                  icon: const Icon(Icons.delete),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          TextEditingController controller = TextEditingController();
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Add a note'),
              content: TextField(
                controller: controller,
              ),
              actions: [
                TextButton(
                  onPressed: Navigator.of(context).pop,
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () async {
                    await Supabase.instance.client
                        .from('notes')
                        .insert({'body': controller.text}).then(
                            (value) => {Navigator.pop(context)});
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
