{{ config(materialized='table') }}

SELECT
  m.match_id,
  m.match_date,
  m.season,
  m.city,
  m.venue,
  m.team1,
  m.team2,
  m.toss_winner,
  m.toss_decision,
  m.winner,
  m.result,
  m.result_margin,
  m.player_of_match,

  -- First innings stats
  SUM(CASE WHEN d.inning = 1 THEN d.total_runs ELSE 0 END) as first_innings_runs,
  COUNT(DISTINCT CASE WHEN d.inning = 1 AND d.is_wicket = 1 THEN d.player_dismissed END) as first_innings_wickets,

  -- Second innings stats
  SUM(CASE WHEN d.inning = 2 THEN d.total_runs ELSE 0 END) as second_innings_runs,
  COUNT(DISTINCT CASE WHEN d.inning = 2 AND d.is_wicket = 1 THEN d.player_dismissed END) as second_innings_wickets

FROM {{ ref('stg_matches') }} m
LEFT JOIN {{ ref('stg_deliveries') }} d
  ON m.match_id = d.match_id
GROUP BY 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13