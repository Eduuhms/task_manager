## 1. Implementações Realizadas

- Implementação completa da interface de lista e formulário de tarefas seguindo Material Design 3.
- Persistência local usando SQLite (sqflite) através de `DatabaseService` com criação/atualização de tabela.
- CRUD de tarefas: criar, ler, atualizar e deletar tarefas.
- Formulário de tarefa com validação (título obrigatório, tamanho mínimo).
- Filtros por status (Todas / Pendentes / Concluídas) e filtro por categoria.
- Campo de Data de Vencimento (dueDate) com DatePicker e apresentação no card.
- Sistema de Categorias (modelo `Category`) com dropdown no formulário, filtro por categoria e indicação visual (cor + label) no card.
- Ordenação por data de vencimento (tarefas com dueDate aparecem antes; tarefas sem dueDate aparecem depois) e destaque visual para tarefas vencidas (não concluídas).
- Card customizado (`TaskCard`) com prioridade, categoria, data/horário e ações (marcar como concluída, apagar, abrir para editar).
- Feedbacks de UX: SnackBars para sucesso/erro, dialog de confirmação ao deletar e estados de loading.

Componentes Material Design 3 utilizados

- AppBar, Card, FloatingActionButton, TextFormField, DropdownButtonFormField, SwitchListTile
- PopupMenuButton (filtros), SnackBar, AlertDialog, RefreshIndicator
- Uso de ThemeData com Material3 e componentes com bordas arredondadas para estética atualizada

## 2. Desafios Encontrados

- Migração de esquema do banco: o exercício pediu novos campos (`dueDate`, `categoryId`) depois do esquema inicial. Solução: atualizei `DatabaseService` para usar versão 2 e implementei `onUpgrade` que adiciona as colunas via `ALTER TABLE` quando necessário.
- Inicialização do `sqflite` em desktop: o pacote `sqflite_common_ffi` precisa inicializar o `databaseFactory` em ambientes desktop; resolvi chamando `sqfliteFfiInit()` e `databaseFactory = databaseFactoryFfi` no ponto de acesso ao banco para garantir inicialização mesmo quando não houve configuração em `main()` (pode ser movido para `main.dart` se preferir evitar o aviso global do sqflite).
- Mostrar e editar a data de vencimento: inicialmente a data não aparecia no campo do formulário. Solução: adicionei um `TextEditingController` (`_dueDateController`) e um `TextFormField` `readOnly` que abre o `showDatePicker` no `onTap`, preenchendo o controller com a data selecionada (formato dd/MM/yyyy). Assim funciona tanto na criação quanto na edição.

## 3. Melhorias Implementadas


- Adicionei o campo de Data de Vencimento com ordenação e destaque para vencidas.
- Implementei categorias pré-definidas com cor e filtro por categoria.
- Ordenação por dueDate e fallback por createdAt para tarefas sem dueDate.
- Melhoria no UX do formulário: feedbacks, botões estilizados e validação robusta.

- Customizações feitas:
  - `TaskCard` mostra prioridade, categoria (cor + nome) e dueDate; tarefas vencidas aparecem com ícone/texto em vermelho.
  - Card de estatísticas com gradiente e contadores (total/pendentes/concluídas).

## 4. Aprendizados

- Integração com SQLite no Flutter: entender como mapear DateTime para ISO strings, lidar com tipos nulos e migrar schema sem perder dados.
- Diferenças de plataforma: `sqflite_common_ffi` para desktop exige inicialização diferente (FFI) comparado ao mobile.
- Boas práticas de UX: tratar estados de loading, confirmar ações destrutivas, e oferecer feedback claro ao usuário.
- Organização do projeto: separar modelos, serviços, telas e widgets facilita manutenção e futuras extensões (ex.: persistência de categorias).

## 5. Próximos Passos

- Persistir categorias no banco (`categories` table) e permitir CRUD de categorias pelo usuário.
- Integrar notificações locais para alertar tarefas próximas do vencimento.
- Adicionar testes automatizados (widget tests) cobrindo criação/edição/deleção e filtros.