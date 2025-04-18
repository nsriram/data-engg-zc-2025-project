{{ config(materialized='view') }}

SELECT
    match_id,
    inning,
    batting_team,
    bowling_team,
    `over`,
    ball,
    batter,
    bowler,
    non_striker,
    batsman_runs,
    extra_runs,
    total_runs,
    extras_type,
    is_wicket,
    player_dismissed,
    dismissal_kind,
    fielder
FROM {{ source('ipl_data', 'deliveries') }}