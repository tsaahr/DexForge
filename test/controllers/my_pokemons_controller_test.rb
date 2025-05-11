require "test_helper"

class MyPokemonsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get my_pokemons_index_url
    assert_response :success
  end
end
