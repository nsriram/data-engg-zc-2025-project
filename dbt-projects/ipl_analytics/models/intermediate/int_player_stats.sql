{{ config(materialized='table') }}

WITH individual_innings AS (
  SELECT
    d.batter as player_name,
    m.season,
    d.match_id,
    d.inning,
    SUM(d.batsman_runs) as runs_scored
  FROM {{ ref('stg_deliveries') }} d
  JOIN {{ ref('stg_matches') }} m
    ON d.match_id = m.match_id
  GROUP BY player_name, season, d.match_id, d.inning
),

batting_stats AS (
  SELECT
    d.batter as player_name,
    m.season,
    COUNT(DISTINCT d.match_id) as matches_played,
    SUM(d.batsman_runs) as total_runs,
    COUNT(*) as balls_faced,
    SUM(CASE WHEN d.batsman_runs = 4 THEN 1 ELSE 0 END) as fours,
    SUM(CASE WHEN d.batsman_runs = 6 THEN 1 ELSE 0 END) as sixes,
    SAFE_DIVIDE(SUM(d.batsman_runs) * 100, COUNT(*)) as strike_rate,
    (
      SELECT MAX(runs_scored)
      FROM individual_innings ii
      WHERE ii.player_name = d.batter AND ii.season = m.season
    ) as highest_score
  FROM {{ ref('stg_deliveries') }} d
  JOIN {{ ref('stg_matches') }} m
    ON d.match_id = m.match_id
  GROUP BY player_name, m.season
),

bowling_stats AS (
  SELECT
    d.bowler as player_name,
    m.season,
    COUNT(DISTINCT d.match_id) as matches_bowled,
    COUNT(*) as balls_bowled,
    SUM(CASE WHEN d.extras_type != 'wides' AND d.extras_type != 'noballs' THEN 1 ELSE 0 END) as legal_balls,
    SUM(d.total_runs) as runs_conceded,
    SUM(d.is_wicket) as wickets,
    COUNT(DISTINCT CONCAT(d.match_id, d.inning)) as innings_bowled,
    SAFE_DIVIDE(SUM(d.total_runs), FLOOR(COUNT(*)/6)) as economy_rate
  FROM {{ ref('stg_deliveries') }} d
  JOIN {{ ref('stg_matches') }} m
    ON d.match_id = m.match_id
  GROUP BY player_name, m.season
)

SELECT
    COALESCE(bat.player_name, bowl.player_name) as player_name,
    COALESCE(bat.season, bowl.season) as season,

    -- Batting metrics
    COALESCE(bat.matches_played, 0) as batting_matches,
    COALESCE(bat.total_runs, 0) as runs_scored,
    COALESCE(bat.balls_faced, 0) as balls_faced,
    COALESCE(bat.fours, 0) as fours,
    COALESCE(bat.sixes, 0) as sixes,
    COALESCE(bat.strike_rate, 0) as batting_strike_rate,
    COALESCE(bat.highest_score, 0) as highest_score,

    -- Bowling metrics
    COALESCE(bowl.matches_bowled, 0) as bowling_matches,
    COALESCE(bowl.balls_bowled, 0) as balls_bowled,
    COALESCE(bowl.legal_balls, 0) as legal_deliveries,
    COALESCE(bowl.runs_conceded, 0) as runs_conceded,
    COALESCE(bowl.wickets, 0) as wickets_taken,
    COALESCE(bowl.economy_rate, 0) as economy_rate

FROM batting_stats bat
         FULL OUTER JOIN bowling_stats bowl
                         ON bat.player_name = bowl.player_name AND bat.season = bowl.season
