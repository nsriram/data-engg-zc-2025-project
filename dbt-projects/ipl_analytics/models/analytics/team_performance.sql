{{ config(materialized='table') }}

WITH team_match_scores AS (
  -- Get total runs scored per team per match
  SELECT
    match_id,
    batting_team AS team_name,
    SUM(total_runs) AS runs_scored
  FROM {{ ref('stg_deliveries') }}
  GROUP BY match_id, batting_team
),

team_matches AS (
  -- Create one row per team per match with their own stats
  SELECT
    m.match_id,
    m.season,
    tms.team_name,
    CASE WHEN tms.team_name = m.winner THEN 1 ELSE 0 END AS is_win,
    tms.runs_scored,
    opp.runs_scored AS runs_conceded
  FROM {{ ref('stg_matches') }} m

  JOIN team_match_scores tms
    ON m.match_id = tms.match_id

  JOIN team_match_scores opp
    ON m.match_id = opp.match_id
   AND tms.team_name != opp.team_name

  WHERE tms.team_name IN (m.team1, m.team2)
)

SELECT
    season,
    team_name,
    COUNT(*) AS matches_played,
    SUM(is_win) AS matches_won,
    COUNT(*) - SUM(is_win) AS matches_lost,
    ROUND(SAFE_DIVIDE(SUM(runs_scored), COUNT(*)), 2) AS avg_runs_scored,
    ROUND(SAFE_DIVIDE(SUM(runs_conceded), COUNT(*)), 2) AS avg_runs_conceded,
    ROUND(SAFE_DIVIDE(SUM(is_win) * 100, COUNT(*)), 2) AS win_percentage
FROM team_matches
GROUP BY season, team_name
ORDER BY season, team_name
