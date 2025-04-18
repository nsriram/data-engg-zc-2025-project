# BigQuery dataset for IPL data
resource "google_bigquery_dataset" "ipl_dataset" {
  dataset_id    = "ipl_data"
  friendly_name = "IPL Cricket Data 2008 to 2024"
  description   = "Dataset containing IPL cricket matches and deliveries data from 2008 to 2024"
  location = var.region
  default_table_expiration_ms = null

  labels = {
    environment = "development"
    data        = "sports"
  }
}

# Create matches table
resource "google_bigquery_table" "matches" {
  dataset_id = google_bigquery_dataset.ipl_dataset.dataset_id
  table_id   = "matches"

  schema = <<EOF
[
  {
    "name": "id",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Match ID"
  },
  {
    "name": "season",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "IPL season year"
  },
  {
    "name": "city",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "City where match was played"
  },
  {
    "name": "date",
    "type": "DATE",
    "mode": "REQUIRED",
    "description": "Date of the match"
  },
  {
    "name": "match_type",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Type of the match"
  },
  {
    "name": "player_of_match",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Player of the match"
  },
  {
    "name": "venue",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Stadium venue"
  },
  {
    "name": "team1",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "First team"
  },
  {
    "name": "team2",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Second team"
  },
  {
    "name": "toss_winner",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Team that won the toss"
  },
  {
    "name": "toss_decision",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Decision after winning toss (bat/field)"
  },
  {
    "name": "winner",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Team that won the match"
  },
  {
    "name": "result",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Result type (runs/wickets/tie/no result)"
  },
  {
    "name": "result_margin",
    "type": "FLOAT",
    "mode": "NULLABLE",
    "description": "Margin of victory"
  },
  {
    "name": "target_runs",
    "type": "FLOAT",
    "mode": "NULLABLE",
    "description": "Target runs"
  },
  {
    "name": "target_overs",
    "type": "FLOAT",
    "mode": "NULLABLE",
    "description": "Target overs"
  },
  {
    "name": "super_over",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Super over information"
  },
  {
    "name": "method",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Method used for result calculation"
  },
  {
    "name": "umpire1",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "First umpire"
  },
  {
    "name": "umpire2",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Second umpire"
  }
]
EOF

  time_partitioning {
    type  = "DAY"
    field = "date"
  }

  clustering = ["season", "city"]

  description = "IPL cricket matches data from 2008-2024"
}

# Create deliveries table
resource "google_bigquery_table" "deliveries" {
  dataset_id = google_bigquery_dataset.ipl_dataset.dataset_id
  table_id   = "deliveries"

  schema = <<EOF
[
  {
    "name": "match_id",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Match ID (foreign key to matches table)"
  },
  {
    "name": "inning",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Inning number"
  },
  {
    "name": "batting_team",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Team that is batting"
  },
  {
    "name": "bowling_team",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Team that is bowling"
  },
  {
    "name": "over",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Over number"
  },
  {
    "name": "ball",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Ball number in the over"
  },
  {
    "name": "batter",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Batsman facing the delivery"
  },
  {
    "name": "bowler",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Bowler bowling the delivery"
  },
  {
    "name": "non_striker",
    "type": "STRING",
    "mode": "REQUIRED",
    "description": "Batsman at non-striker end"
  },
  {
    "name": "batsman_runs",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Runs scored by batsman"
  },
  {
    "name": "extra_runs",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Extra runs"
  },
  {
    "name": "total_runs",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Total runs scored on the delivery"
  },
  {
    "name": "extras_type",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Type of extras (wide/no-ball/leg-bye/etc)"
  },
  {
    "name": "is_wicket",
    "type": "INTEGER",
    "mode": "REQUIRED",
    "description": "Indicates if a wicket fell on this delivery (0/1)"
  },
  {
    "name": "player_dismissed",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Player who got dismissed"
  },
  {
    "name": "dismissal_kind",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Type of dismissal"
  },
  {
    "name": "fielder",
    "type": "STRING",
    "mode": "NULLABLE",
    "description": "Fielder involved in the dismissal"
  }
]
EOF

  clustering = ["match_id", "inning", "over"]

  description = "IPL cricket deliveries data from 2008-2024"
}