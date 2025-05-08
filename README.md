POKEDEX APP

This is a personal project: a simple Pokédex built using Ruby on Rails and the PokéAPI.
The main goal was to practice backend development, API integration, and display dynamic content in a clean and organized interface.
Description

    All Pokémon are fetched from the PokéAPI and stored in a local SQLite database.

    This approach keeps the index page lightweight and fast.

    The index displays all Pokémon with their name and sprite.

    The show page fetches detailed information in real time from the PokéAPI.

Features

    List of Pokémon from local database

    Individual detail pages with:

        Name

        Image (sprite)

        Height

        Weight

        Types (displayed as badges)

Technologies Used

    Ruby on Rails

    SQLite3

    HTTParty

    PokéAPI

    Bootstrap 5

Notes

    This project uses SQLite3 as the database.

    Only basic Pokémon info is stored (name, image, pokeapi ID).

    The detail page fetches live data from the PokéAPI each time it is accessed.

    Type advantages and advanced battle logic are not yet implemented.