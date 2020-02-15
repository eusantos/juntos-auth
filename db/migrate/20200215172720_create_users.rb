class CreateUsers < ActiveRecord::Migration[5.0]
  def change
    create_table :users do |t|
      t.string :login
      t.string :password
      t.string :email
      t.string :token
      t.datetime :token_exp

      t.timestamps
    end
  end
end
