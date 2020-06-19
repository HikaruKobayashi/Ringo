namespace :push_line do 
  desc "Ringo" 
  task push_line_message: :environment do
      message = {
          type: 'text',
          text: 'ロックであるとかないとか言ってるアンタが一番ロックじゃねえんだよ。'
      }
      client = Line::Bot::Client.new { |config|
          config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
          config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
      }
      response = client.push_message(ENV["LINE_CHANNEL_USER_ID"], message)
  end
end