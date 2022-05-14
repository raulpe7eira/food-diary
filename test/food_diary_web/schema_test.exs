defmodule FoodDiaryWeb.SchemaTest do
  use FoodDiaryWeb.ConnCase, async: true
  use FoodDiaryWeb.SubscriptionCase

  alias FoodDiary.{User, Users}

  describe "users query" do
    test "when a valid id is given, returns the user", %{conn: conn} do
      params = %{email: "fulano@mail.com", name: "Fulano"}

      {:ok, %User{id: user_id}} = Users.Create.call(params)

      query = """
        query {
          user(id: "#{user_id}") {
            name,
            email
          }
        }
      """

      expected_response = %{
        "data" => %{"user" => %{"email" => "fulano@mail.com", "name" => "Fulano"}}
      }

      response =
        conn
        |> post("api/graphql", %{query: query})
        |> json_response(:ok)

      assert response == expected_response
    end

    test "when the user does not exist, returns an error", %{conn: conn} do
      query = """
        query {
          user(id: "1234") {
            name,
            email
          }
        }
      """

      expected_response = %{
        "data" => %{"user" => nil},
        "errors" => [
          %{
            "locations" => [%{"column" => 5, "line" => 2}],
            "message" => "User not found",
            "path" => ["user"]
          }
        ]
      }

      response =
        conn
        |> post("api/graphql", %{query: query})
        |> json_response(:ok)

      assert response == expected_response
    end
  end

  describe "users mutation" do
    test "when all params are valid, creates the user", %{conn: conn} do
      mutation = """
        mutation {
          createUser(input: {email: "fulano@mail.com", name: "Fulano"}) {
            id,
            name,
            email
          }
        }
      """

      response =
        conn
        |> post("api/graphql", %{query: mutation})
        |> json_response(:ok)

      assert %{
               "data" => %{
                 "createUser" => %{
                   "id" => _id,
                   "email" => "fulano@mail.com",
                   "name" => "Fulano"
                 }
               }
             } = response
    end
  end

  describe "subscriptions" do
    test "meals subscription", %{socket: socket} do
      params = %{email: "fulano@mail.com", name: "Fulano"}

      {:ok, %User{id: user_id}} = Users.Create.call(params)

      subscription = """
        subscription {
          newMeal {
            description
          }
        }
      """

      # Setup subscription
      socket_ref = push_doc(socket, subscription)
      assert_reply socket_ref, :ok, %{subscriptionId: subscription_id}, 700

      mutation = """
        mutation {
          createMeal(input: {
            userId: #{user_id},
            description: "Pizza",
            calories: 370.50,
            category: FOOD
          }){
            description,
            calories,
            category
          }
        }
      """

      # Call mutation
      socket_ref = push_doc(socket, mutation)
      assert_reply socket_ref, :ok, mutation_response, 700

      expected_mutation_response = %{
        data: %{
          "createMeal" => %{
            "calories" => 370.5,
            "category" => "FOOD",
            "description" => "Pizza"
          }
        }
      }

      assert mutation_response == expected_mutation_response

      # Validate subscription
      expected_subscription_response = %{
        result: %{data: %{"newMeal" => %{"description" => "Pizza"}}},
        subscriptionId: subscription_id
      }

      assert_push "subscription:data", subscription_response
      assert subscription_response == expected_subscription_response

      refute_push "subscription:data", %{}
    end
  end
end
