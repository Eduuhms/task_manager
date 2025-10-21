# AULA 1: Fundamentos e Persistência Local com SQLite

## Objetivos

  - **Configurar** projeto Flutter
  - **Implementar** modelo de dados
  - **Criar** serviço de banco de dados SQLite
  - **Desenvolver** CRUD básico

-----

## Prática (90min)

### 1.1 Setup Inicial

Começamos criando um novo projeto Flutter com o comando `flutter create` e, em seguida, navegamos para o diretório do projeto recém-criado.

```bash
flutter create task_manager
cd task_manager
flutter run
```

### 1.2 Dependências (pubspec.yaml)

O arquivo `pubspec.yaml` é onde gerenciamos as dependências do nosso projeto. Adicionamos os seguintes pacotes:

  - **sqflite**: O principal pacote para interagir com bancos de dados SQLite no Flutter.
  - **path\_provider**: Para encontrar o caminho correto no sistema de arquivos do dispositivo onde o banco de dados será armazenado.
  - **path**: Utilitários para manipular caminhos de arquivos.
  - **uuid**: Para gerar IDs únicos para cada tarefa.
  - **intl**: Usado para formatação de datas.

<!-- end list -->

```yaml
dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0
  path_provider: ^2.1.1
  path: ^1.8.3
  uuid: ^4.2.1
  intl: ^0.19.0
```

### 1.3 Modelo de Dados (lib/models/task.dart)

Este arquivo define a estrutura de dados da nossa tarefa. A classe `Task` representa o nosso "modelo" (Model). Ela contém os campos que uma tarefa terá (id, título, etc.) e métodos úteis para conversão de dados:

  - **`toMap()`**: Converte o objeto `Task` em um `Map`, que é o formato que o `sqflite` usa para inserir dados no banco.
  - **`fromMap()`**: Faz o processo inverso, criando um objeto `Task` a partir de um `Map` vindo do banco de dados.
  - **`copyWith()`**: Um método auxiliar para criar uma cópia de uma tarefa, modificando apenas alguns campos, útil para atualizações.

<!-- end list -->

```dart
import 'package:uuid/uuid.dart';

class Task {
  final String id;
  final String title;
  final String description;
  final bool completed;
  final String priority;
  final DateTime createdAt;

  Task({
    String? id,
    required this.title,
    this.description = '',
    this.completed = false,
    this.priority = 'medium',
    DateTime? createdAt,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'completed': completed ? 1 : 0,
      'priority': priority,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'],
      title: map['title'],
      description: map['description'] ?? '',
      completed: map['completed'] == 1,
      priority: map['priority'] ?? 'medium',
      createdAt: DateTime.parse(map['createdAt']),
    );
  }

  Task copyWith({
    String? title,
    String? description,
    bool? completed,
    String? priority,
  }) {
    return Task(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      completed: completed ?? this.completed,
      priority: priority ?? this.priority,
      createdAt: createdAt,
    );
  }
}
```

### 1.4 Database Service (lib/services/database\_service.dart)

Esta é a classe central para a lógica de banco de dados. Ela segue o padrão Singleton, garantindo que tenhamos apenas uma instância da conexão com o banco em todo o app.

  - **`_initDB()`**: Inicializa o banco de dados, define seu nome e caminho.
  - **`_createDB()`**: É chamado na primeira vez que o banco é criado e executa o comando SQL para criar a tabela `tasks` com suas respectivas colunas.
  - **Métodos CRUD**: `create`, `read`, `readAll`, `update`, e `delete` são os métodos públicos que nossa UI usará para interagir com o banco de dados, abstraindo a complexidade das queries SQL.

<!-- end list -->

```dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/task.dart';

class DatabaseService {
  static final DatabaseService instance = DatabaseService._init();
  static Database? _database;

  DatabaseService._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE tasks (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        description TEXT,
        completed INTEGER NOT NULL,
        priority TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');
  }

  Future<Task> create(Task task) async {
    final db = await database;
    await db.insert('tasks', task.toMap());
    return task;
  }

  Future<Task?> read(String id) async {
    final db = await database;
    final maps = await db.query(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Task.fromMap(maps.first);
    }
    return null;
  }

  Future<List<Task>> readAll() async {
    final db = await database;
    const orderBy = 'createdAt DESC';
    final result = await db.query('tasks', orderBy: orderBy);
    return result.map((map) => Task.fromMap(map)).toList();
  }

  Future<int> update(Task task) async {
    final db = await database;
    return db.update(
      'tasks',
      task.toMap(),
      where: 'id = ?',
      whereArgs: [task.id],
    );
  }

  Future<int> delete(String id) async {
    final db = await database;
    return await db.delete(
      'tasks',
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
```

### 1.5 Tela Simples (lib/screens/task\_list\_screen.dart)

Este widget é a interface do usuário (UI) da nossa aplicação. Ele é um `StatefulWidget` porque seu conteúdo (a lista de tarefas) precisa mudar dinamicamente.

  - **`_loadTasks()`**: Carrega as tarefas do banco de dados usando nosso `DatabaseService` e atualiza o estado da tela com `setState`.
  - **`_addTask()`**: Pega o texto do `TextField`, cria um novo objeto `Task` e o salva no banco.
  - **`_toggleTask()`** e **`_deleteTask()`**: Lidam com as ações de marcar uma tarefa como concluída e de excluí-la, respectivamente.
  - **`build()`**: Constrói a árvore de widgets, que inclui um `AppBar`, um `TextField` para adicionar novas tarefas e um `ListView.builder` para exibir a lista de tarefas de forma eficiente.

<!-- end list -->

```dart
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/database_service.dart';

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({Key? key}) : super(key: key);

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  List<Task> _tasks = [];
  final _titleController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await DatabaseService.instance.readAll();
    setState(() => _tasks = tasks);
  }

  Future<void> _addTask() async {
    if (_titleController.text.trim().isEmpty) return;

    final task = Task(title: _titleController.text.trim());
    await DatabaseService.instance.create(task);
    _titleController.clear();
    _loadTasks();
  }

  Future<void> _toggleTask(Task task) async {
    final updated = task.copyWith(completed: !task.completed);
    await DatabaseService.instance.update(updated);
    _loadTasks();
  }

  Future<void> _deleteTask(String id) async {
    await DatabaseService.instance.delete(id);
    _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Minhas Tarefas'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      hintText: 'Nova tarefa...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addTask,
                  child: const Text('Adicionar'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _tasks.length,
              itemBuilder: (context, index) {
                final task = _tasks[index];
                return ListTile(
                  leading: Checkbox(
                    value: task.completed,
                    onChanged: (_) => _toggleTask(task),
                  ),
                  title: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.completed
                          ? TextDecoration.lineThrough
                          : null,
                    ),
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteTask(task.id),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```

### 1.6 Main (lib/main.dart)

Este é o ponto de entrada da nossa aplicação Flutter. A função `main()` chama `runApp()` para iniciar o app. O widget `MyApp` configura o `MaterialApp`, que define o tema global, o título e a tela inicial (`home`), que será a nossa `TaskListScreen`.

```dart
import 'package:flutter/material.dart';
import 'screens/task_list_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Task Manager',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const TaskListScreen(),
    );
  }
}
```

-----

## Exercício Prático

  - Adicionar campo "prioridade" com dropdown
  - Implementar filtro por status (todas/completas/pendentes)
  - Adicionar contador de tarefas

-----

## Entregável Aula 1

✅ App funcionando com CRUD completo de tarefas em SQLite.