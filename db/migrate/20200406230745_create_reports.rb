# From the Google Maps documentation: "To keep the storage space required for your table at a minimum, you can specify that the lat and lng attributes are floats of size (10,6)"
class CreateReports < ActiveRecord::Migration[6.0]
  def change
    create_table :reports do |t|
      t.text :description
      t.string :status
      t.decimal :lat, {precision: 10, scale: 6}
      t.decimal :lng, {precision: 10, scale: 6}
      t.references :user, null: false, foreign_key: true
      t.text :response

      t.timestamps
    end
    add_index :reports, :description
  end
end
