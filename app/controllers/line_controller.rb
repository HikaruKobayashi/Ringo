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
      if message == "愛してる"
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            message = {
              type: 'text',
              text: '「人生っていうのは勝手に与えられるんだから、自分が追求してもいいんだ。幸せ追求権ってあるだろう！」と思ったんですね。'
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
      else
        case event
        when Line::Bot::Event::Message
          case event.type
          when Line::Bot::Event::MessageType::Text
            message = {
              type: 'text',
              text: @post.reply
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
      end
    }

    head :ok
  end
end