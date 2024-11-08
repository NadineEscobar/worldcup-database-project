#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# No cambiar el código anterior. Usar la variable PSQL para hacer consultas en la base de datos.

# Limpiar las tablas antes de cargar los datos (para evitar duplicados en cada ejecución)
echo "$($PSQL "TRUNCATE TABLE games, teams")"

# Leer el archivo CSV y procesar cada línea
while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  # Saltar la primera fila (encabezados)
  if [[ $YEAR != "year" ]]
  then
    # Insertar equipo ganador en la tabla teams si no existe
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    if [[ -z $WINNER_ID ]]
    then
      INSERT_WINNER_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_RESULT == "INSERT 0 1" ]]
      then
        echo "Equipo insertado: $WINNER"
      fi
      # Obtener el ID del equipo ganador después de insertarlo
      WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # Insertar equipo oponente en la tabla teams si no existe
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    if [[ -z $OPPONENT_ID ]]
    then
      INSERT_OPPONENT_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_RESULT == "INSERT 0 1" ]]
      then
        echo "Equipo insertado: $OPPONENT"
      fi
      # Obtener el ID del equipo oponente después de insertarlo
      OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # Insertar juego en la tabla games
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Juego insertado: $YEAR $ROUND - $WINNER vs $OPPONENT"
    fi
  fi
done < games.csv
