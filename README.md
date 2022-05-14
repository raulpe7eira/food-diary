# FoodDiary API

This repository is the code corresponding to the [Ignite, Module: Elixir and GraphQL with Absinthe](https://app.rocketseat.com.br/node/elixir-e-graphql-com-absinthe-2022) lab.

> The project simulates a Food Diary management API that allows to register users and meals with GraphQL.

## Previous installations

**Database**, we recommends install [PostgreSQL](https://www.postgresql.org/) with [Docker](https://hub.docker.com/_/postgres). After that, sets connection configuration at:

- `config/dev.exs`
- `config/test.exs`

## Gets dependencies, setups database, tests, coverages, reports and starts application

```bash
cd food-diary
mix deps.get
mix ecto.setup
mix test
mix test --cover
mix phx.server
```

## How to use?

```bash
# provides resources graphql
curl -X POST 'http://localhost:4000/api/graphql'

# provides resources graphql with web development interface
curl -X POST 'http://localhost:4000/api/graphiql'
```

### Resources GraphQL

```bash
# retrieves user
query {
  user(id: 1) {
    email,
    name
  }
}

# creates user
mutation {
  createUser(input: {
    email: "fulano@mail.com",
    name: "Fulano"
  }) {
    id
  }
}

# creates meal
mutation {
  createMeal(input: {
    userId: 3,
    description: "Pizza",
    calories: 370.50,
    category: FOOD
  }) {
    id
  }
}

# listens new meal
subscription {
  newMeal {
    description
  }
}
```
