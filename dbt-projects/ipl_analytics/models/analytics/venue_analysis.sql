{{ config(materialized='table') }}

SELECT
    venue,
    city,
    season,
    COUNT(*) as matches_played,
    AVG(first_innings_runs) as avg_first_innings_score,
    AVG(second_innings_runs) as avg_second_innings_score,
    SUM(CASE WHEN toss_winner = winner THEN 1 ELSE 0 END) as toss_winner_won_match,
    SUM(CASE WHEN toss_decision = 'bat' THEN 1 ELSE 0 END) as chose_to_bat_first,
    SUM(CASE WHEN toss_decision = 'field' THEN 1 ELSE 0 END) as chose_to_field_first,
    SUM(CASE WHEN toss_decision = 'bat' AND toss_winner = winner THEN 1 ELSE 0 END) as batting_first_wins,
    SUM(CASE WHEN toss_decision = 'field' AND toss_winner = winner THEN 1 ELSE 0 END) as fielding_first_wins
FROM {{ ref('int_match_summary') }}
GROUP BY venue, city, season