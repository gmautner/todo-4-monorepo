# Changelog

## [Não Lançado]

### Adicionado
- Estrutura inicial do projeto com Next.js (App Router, TypeScript, Tailwind CSS)
- Arquivos de documentação inicial (README.md, docs/FEATURES.md, docs/CHANGELOG.md)
- Configuração do Shadcn UI e ThemeProvider (Temas Claro/Escuro/Sistema)
- Configuração do Drizzle ORM com conexão ao banco de dados Postgres (Docker)
- Schema inicial do banco de dados (`tasks` table) e migrações
- Componentes Shadcn UI básicos (Button, Card, Badge, Dialog, Input, etc.) e componente `DatePicker` customizado
- Componente `TaskItem` para exibição de tarefas individuais
- Server Actions para criar, atualizar, marcar como concluída/pendente e excluir tarefas (`createTask`, `updateTask`, `toggleTaskStatus`, `deleteTask`)
- Componente `NewTaskForm` para adicionar novas tarefas (com validação Zod e notificações Sonner)
- Componente `EditTaskForm` para editar tarefas existentes
- Componente cliente `TaskList` para gerenciar a renderização da lista e o estado de edição
- Funcionalidade de listar, adicionar, concluir/desconcluir, excluir e editar tarefas na interface principal

### Modificado
- Refatorada a página principal (`page.tsx`) para usar `TaskList`

### Corrigido
- Problemas de configuração do Drizzle Kit com variáveis de ambiente (`.env`)
- Erros de tipo e linter relacionados à integração de `react-hook-form`, `zodResolver` e componentes controlados (Select, DatePicker)
- Importações de componentes Shadcn UI após falhas iniciais na adição 