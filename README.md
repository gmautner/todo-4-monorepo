# Aplicação de Lista de Tarefas

Esta é uma aplicação de lista de tarefas desenvolvida com Next.js, TypeScript, Tailwind CSS, Shadcn UI e Drizzle ORM.

## Funcionalidades Principais

Consulte o arquivo `docs/FEATURES.md` para a lista completa de funcionalidades planejadas e o progresso atual.

## Changelog

Consulte o arquivo `docs/CHANGELOG.md` para o histórico de alterações.

## Configuração do Ambiente de Desenvolvimento

### Pré-requisitos

- Node.js (versão recomendada: 20.x ou superior)
- pnpm (gerenciador de pacotes)
- Docker (para rodar o banco de dados Postgres)

### Passos

1.  **Clone o repositório:**
    ```bash
    git clone <URL_DO_REPOSITORIO>
    cd <NOME_DA_PASTA_DO_REPOSITORIO>
    ```

2.  **Instale as dependências:**
    ```bash
    pnpm install
    ```

3.  **Configure o Banco de Dados (Postgres com Docker):**
    *   Abra um terminal e execute o seguinte comando para iniciar um container Postgres. Escolha uma senha segura para `<SUA_SENHA>` e uma porta livre (ex: 5433) para `<PORTA_LIVRE>`:
        ```bash
        docker run --name todo-postgres -e POSTGRES_PASSWORD=<SUA_SENHA> -e POSTGRES_DB=todoapp -p <PORTA_LIVRE>:5432 -d postgres
        ```
        (Exemplo: `docker run --name todo-postgres -e POSTGRES_PASSWORD=mysecretpassword -e POSTGRES_DB=todoapp -p 5433:5432 -d postgres`)

    *   Crie um arquivo chamado `.env` dentro da pasta `apps/web`.

    *   Adicione a seguinte linha ao arquivo `.env`, substituindo `<SUA_SENHA>` e `<PORTA_LIVRE>` pelos valores que você usou no comando Docker:
        ```env
        DATABASE_URL="postgresql://postgres:<SUA_SENHA>@localhost:<PORTA_LIVRE>/todoapp?schema=public"
        ```
        (Exemplo: `DATABASE_URL="postgresql://postgres:mysecretpassword@localhost:5433/todoapp?schema=public"`)

4.  **Execute as Migrations do Banco de Dados:**
    *   Navegue até a pasta da aplicação web:
        ```bash
        cd apps/web
        ```
    *   (Este passo será adicionado após a configuração do Drizzle)
        ```bash
        # pnpm db:push # ou comando similar
        ```

5.  **Inicie o Servidor de Desenvolvimento:**
    *   Ainda dentro da pasta `apps/web`:
        ```bash
        pnpm dev
        ```

6.  **Acesse a Aplicação:**
    *   Abra seu navegador e acesse [http://localhost:3000](http://localhost:3000).

## Build e Deploy (Docker)

Instruções para build e deploy com Docker serão adicionadas posteriormente. 