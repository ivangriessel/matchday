class CreateFixtures < ActiveRecord::Migration[8.1]
  def change
    create_table :fixtures do |t|
      t.string :season, null: false
      t.integer :gameweek, null: false
      t.integer :home_team_id, null: false
      t.integer :away_team_id, null: false
      t.datetime :kickoff_at, null: false
      t.integer :home_score
      t.integer :away_score
      t.string :status, null: false, default: "scheduled"

      t.timestamps
    end

    add_index :fixtures, :gameweek
    add_index :fixtures, :home_team_id
    add_index :fixtures, :away_team_id
    add_index :fixtures, :kickoff_at

    add_foreign_key :fixtures, :teams, column: :home_team_id
    add_foreign_key :fixtures, :teams, column: :away_team_id
  end
end
