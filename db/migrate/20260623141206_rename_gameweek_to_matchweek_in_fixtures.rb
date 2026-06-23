class RenameGameweekToMatchweekInFixtures < ActiveRecord::Migration[8.1]
  def change
    rename_column :fixtures, :gameweek, :matchweek
  end
end
