class CreateGisMapsRelations < ActiveRecord::Migration
  def change
    create_table :gis_maps_relations, {:id => false} do |t|
      t.column :rid, :serial
      t.column :map_id, :integer
      t.column :relation_id, :integer
      t.column :sort_no,  :integer
      t.column :created_at, :timestamp
      t.column :created_user, :text
      t.column :created_group, :text
      t.column :updated_at, :timestamp
      t.column :updated_user, :text
      t.column :updated_group, :text
      t.column :deleted_at, :timestamp
      t.column :deleted_user, :text
      t.column :deleted_group, :text
      t.timestamps
    end
    execute "ALTER TABLE gis_maps_relations ADD PRIMARY KEY (rid);"

  end
end
