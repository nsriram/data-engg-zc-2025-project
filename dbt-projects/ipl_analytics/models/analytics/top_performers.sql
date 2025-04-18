{{ config(materialized='table') }}

-- Top batsmen by season
WITH top_batsmen AS (
  SELECT
    season,
    player_name,
    runs_scored,
    balls_faced,
    batting_strike_rate,
    ROW_NUMBER() OVER (PARTITION BY season ORDER BY runs_scored DESC) as batting_rank
  FROM {{ ref('int_player_stats') }}
  WHERE runs_scored > 0
),

-- Top bowlers by season
top_bowlers AS (
  SELECT
    season,
    player_name,
    wickets_taken,
    runs_conceded,
    economy_rate,
    ROW_NUMBER() OVER (PARTITION BY season ORDER BY wickets_taken DESC) as bowling_rank
  FROM {{ ref('int_player_stats') }}
  WHERE wickets_taken > 0
),

-- All-rounders (good at both batting and bowling)
all_rounders AS (
  SELECT
    season,
    player_name,
    runs_scored,
    wickets_taken,
    (runs_scored * 0.05 + wickets_taken * 4) as all_rounder_index,
    ROW_NUMBER() OVER (PARTITION BY season ORDER BY (runs_scored * 0.05 + wickets_taken * 4) DESC) as all_rounder_rank
  FROM {{ ref('int_player_stats') }}
  WHERE runs_scored > 100 AND wickets_taken > 5
)

-- Final output combining all categories
SELECT
    'batsman' as category,
    season,
    player_name,
    batting_rank as rank,
    runs_scored as primary_stat,
    batting_strike_rate as secondary_stat,
    NULL as tertiary_stat
FROM top_batsmen
WHERE batting_rank <= 10

UNION ALL

SELECT
    'bowler' as category,
    season,
    player_name,
    bowling_rank as rank,
    wickets_taken as primary_stat,
    economy_rate as secondary_stat,
    runs_conceded as tertiary_stat
FROM top_bowlers
WHERE bowling_rank <= 10

UNION ALL

SELECT
    'all_rounder' as category,
    season,
    player_name,
    all_rounder_rank as rank,
    all_rounder_index as primary_stat,
    runs_scored as secondary_stat,
    wickets_taken as tertiary_stat
FROM all_rounders
WHERE all_rounder_rank <= 5