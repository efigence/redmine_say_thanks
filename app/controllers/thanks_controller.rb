class ThanksController < ApplicationController
  unloadable

  before_action :permitted?

  def new
    @new_thanks = User.current.sent_thanks.new
  end

  def create
    @new_thanks = User.current.sent_thanks.new(thanks_params)

    if @new_thanks.save
      flash[:success] = 'Thanks saved!'
    else
      flash[:error] = @new_thanks.errors.full_messages.to_sentence
    end
    redirect_to given_thanks_path
  end

  def given
    @thanks = User.current.sent_thanks
  end

  def received
    @thanks = User.current.received_thanks
    @points = {
      total:    @thanks.where.not(status: 1).count,
      to_spend: @thanks.active.count,
      spent:    @thanks.rewarded.count
    }
  end

  def destroy
  end

  def unroll
    @thanks = Thanks.find(params[:id])
    @thanks.unrolled!
    flash[:notice] = 'Thanks unrolled!'
    redirect_to given_thanks_path
  end

  private

  def thanks_params
    params.require(:thanks).permit(:receiver_id)
  end

  def permitted?
    deny_access unless User.current.can_access_thanks?
  end
end
