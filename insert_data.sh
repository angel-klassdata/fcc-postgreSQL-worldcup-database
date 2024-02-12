#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# truncate tables
echo $($PSQL "TRUNCATE TABLE games, teams")

# get games.csv file
cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then

    # get winner team_id
    WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    
    # if not found
    if [[ -z $WINNER_TEAM_ID ]]
    then
      # insert team
      INSERT_WINNER_ID_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$WINNER')")
      if [[ $INSERT_WINNER_ID_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into team_id winner, $WINNER_TEAM_ID
      fi

      # get new winner team_id
      WINNER_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    # get opponent team_id
    OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    # if not found
    if [[ -z $OPPONENT_TEAM_ID ]]
    then
      # insert team
      INSERT_OPPONENT_ID_RESULT=$($PSQL "INSERT INTO teams(name) VALUES('$OPPONENT')")
      if [[ $INSERT_OPPONENT_ID_RESULT == "INSERT 0 1" ]]
      then
        echo Inserted into team_id opponent, $OPPONENT_TEAM_ID
      fi

      # get new opponent team_id
      OPPONENT_TEAM_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # insert game row
    INSERT_ROW=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', '$WINNER_TEAM_ID', '$OPPONENT_TEAM_ID', $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_ROW == "INSERT 0 1" ]]
    then
      echo Inserted into games, $YEAR $ROUND $WINNER_TEAM_ID $OPPONENT_TEAM_ID $WINNER_GOALS $OPPONENT_GOALS
    fi

  fi

done