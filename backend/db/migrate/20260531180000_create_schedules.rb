class CreateSchedules < ActiveRecord::Migration[7.0]
  def change
    create_table :schedules do |t|
      t.date :date, null: false
      t.json :appointments, null: false, default: []

      t.timestamps
    end

    add_index :schedules, :date, unique: true
  end
end
