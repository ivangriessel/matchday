# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

[
  [ "Arsenal",                 "ARS" ],
  [ "Aston Villa",             "AVL" ],
  [ "Bournemouth",             "BOU" ],
  [ "Brentford",               "BRE" ],
  [ "Brighton & Hove Albion",  "BHA" ],
  [ "Chelsea",                 "CHE" ],
  [ "Coventry City",           "COV" ],
  [ "Crystal Palace",          "CRY" ],
  [ "Everton",                 "EVE" ],
  [ "Fulham",                  "FUL" ],
  [ "Hull City",               "HUL" ],
  [ "Ipswich Town",            "IPS" ],
  [ "Leeds United",            "LEE" ],
  [ "Liverpool",               "LIV" ],
  [ "Manchester City",         "MCI" ],
  [ "Manchester United",       "MUN" ],
  [ "Newcastle United",        "NEW" ],
  [ "Nottingham Forest",       "NFO" ],
  [ "Sunderland",              "SUN" ],
  [ "Tottenham Hotspur",       "TOT" ]
].each do |name, short_code|
  Team.find_or_create_by!(short_code: short_code) do |t|
    t.name = name
  end
end

puts "Seeded #{Team.count} teams."
