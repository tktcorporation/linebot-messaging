class CreateBotSlackApiSet < ActiveRecord::Migration[5.2]
  def change
    create_table :bot_slack_api_sets, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
      t.integer :bot_id, foreign_key: true
      t.string :webhook_url

      t.timestamps
    end
  end
end
