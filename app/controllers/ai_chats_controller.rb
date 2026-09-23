class AiChatsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:create]

  def create
    session_id = params[:session_id].presence || SecureRandom.uuid

    property = nil
    car      = nil
    property = Property.find_by(id: params[:property_id]) if params[:property_id].present?
    car      = Car.find_by(id: params[:car_id])           if params[:car_id].present?

    service = RuleChatbotService.new(
      message:    params[:message].to_s.strip,
      session_id: session_id,
      property:   property,
      car:        car
    )

    reply = service.reply

    render json: { session_id: session_id, reply: reply }
  end

  def history
    messages = ChatMessage.for_session(params[:session_id])
    render json: messages.map { |m| { role: m.role, content: m.content } }
  end
end
