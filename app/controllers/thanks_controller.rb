class ThanksController < ApplicationController
  unloadable

  before_action :permitted?

  def index
    @new_thanks = User.current.sent_thanks.new
  end

  def create
    @new_thanks = User.current.sent_thanks.new(thanks_params)

    if @new_thanks.save
      flash[:success] = 'Thanks saved!'
    else
      flash[:error] = @new_thanks.errors.full_messages.to_sentence
    end
    redirect_to thanks_path
  end

  def destroy
  end

  private

  def thanks_params
    params.require(:thanks).permit(:receiver_id)
  end

  def permitted?
    deny_access unless User.current.can_access_thanks?
  end
end