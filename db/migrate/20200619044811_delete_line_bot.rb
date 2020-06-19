class DeleteLineBot < ActiveRecord::Migration[5.2]
  def change
    drop_table :line_bots
  end
end
