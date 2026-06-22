class CreateTeams < ActiveRecord::Migration[8.1]
  def change
    create_table :teams do |t|
      t.string :name, null: false
      t.string :short_code, null: false
      t.string :crest_url

      t.timestamps
    end

    add_index :teams, :name, unique: true
    add_index :teams, :short_code, unique: true
  end
end
