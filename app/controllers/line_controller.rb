class LineController < ApplicationController
  require 'line/bot'

  protect_from_forgery :except => [:callback]

  def client
    @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
  end

  def callback
    @post=Post.offset( rand(Post.count) ).first
    body = request.body.read

    signature = request.env['HTTP_X_LINE_SIGNATURE']
    unless client.validate_signature(body, signature)
      head :bad_request
    end

    events = client.parse_events_from(body)

    events.each { |event|
      if event.message['text'].include?('罪と?')
        response = '罰'
      elsif event.message['text'].include?('能動的?')
        response = '三分間'
      elsif event.message['text'].include?('電波?')
        response = '通信'
      elsif event.message['text'].include?('酒と?')
        response = '下戸'
      elsif event.message['text'].include?('OS?')
        response = 'CA'
      elsif event.message['text'].include?('ミラー?')
        response = 'ボール'
      elsif event.message['text'].include?('好きな食べ物は?')
        response = 'にんじん'
      elsif event.message['text'].include?('可愛いね。')
        response = '大人になって大好きな人ができて、今まで男の子とチョメチョメしてきたのがリハーサルだったのかと思うぐらい、「私はこの人のために、経験や知識やこれから学ぶこと全部を捧げなければいけない。捧げるべきなんだ」って心に決める。すごく本能的に感じるんですよね。'
      elsif event.message['text'].include?('おはよう。')
        response = '今日も一日良い日になるといいね。'
      elsif event.message['text'].include?('おやすみ。')
        response = '今日もお疲れ様。ゆっくり休んでね。'
      else
        response = @post.reply
      end

      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: response
          }
          client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Follow
          userId = event['source']['userId']
          User.find_or_create_by(uid: userId)
        when Line::Bot::Event::MessageType::Unfollow
          userId = event['source']['userId']
          user = User.find_by(uid: userId)
          user.destroy if user.present?
        end
      end
    }

    head :ok
  end
end