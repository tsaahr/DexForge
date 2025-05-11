DexForge

DexForge is a personal project built with Ruby on Rails that started as a simple Pokédex and has evolved into a more complete application. It integrates user authentication, dynamic data from the PokéAPI, and interactive features for users.

Currently, the system allows:

    Viewing a list of Pokémon fetched from the PokéAPI and stored in a PostgreSQL database.

    Accessing individual Pokémon pages with data such as name, sprite, types, height, weight, stats, and moves.

    Selecting a level for the Pokémon, which dynamically adjusts and displays its stats based on the chosen level.

    Showing the best level-up moves the Pokémon can learn up to the selected level, including name, description, and power.

    User authentication with Devise.

    A "My Pokémons" section where users can view the Pokémon they have captured.

    Evolution system based on level progression.

Planned features include:

    Pokémon capture system.

    Battles between users' Pokémon.

    Implementation of IVs (Individual Values) to personalize Pokémon stats.

    Type-based advantages and disadvantages during battles.

The project uses Ruby on Rails, PostgreSQL, Devise for authentication, and direct integration with the PokéAPI for real-time data. The interface is styled with Bootstrap 5 and aims for a clean, responsive experience.