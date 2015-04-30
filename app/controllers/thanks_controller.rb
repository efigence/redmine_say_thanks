class ThanksController < ApplicationController
  unloadable

  before_action :permitted?

  def index
    @new_thanks = User.current.sent_thanks.new
  end

  def create
    @new_thanks = User.current.sent_thanks.create(thanks_params)
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
