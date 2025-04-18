{{ config(materialized='view') }}

SELECT
    id as match_id,
    date as match_date,
    season,
    city,
    venue,
    team1,
    team2,
    toss_winner,
    toss_decision,
    winner,
    result,
    result_margin,
    player_of_match,
    EXTRACT(YEAR FROM date) as year,
  EXTRACT(MONTH FROM date) as month
FROM {{ source('ipl_data', 'matches') }}