class CreateBotLineuserInvitationCode < ActiveRecord::Migration[5.2]
  def change
    create_table :lineuser_invitation_codes, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :lineuser_id, foreign_key: true
      t.string :code

      t.timestamps
    end
  end
end
