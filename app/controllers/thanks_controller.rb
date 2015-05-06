class ThanksController < BaseThanksController
  unloadable

  def new
    @new_thanks = User.current.sent_thanks.new
  end

  def create
    @new_thanks = User.current.sent_thanks.new(thanks_params)

    if @new_thanks.save
      flash[:notice] = 'Thanks saved!'
      redirect_to given_thanks_path
    else
      flash[:error] = @new_thanks.errors.full_messages.to_sentence
      render :new
    end
  end

  def given
    @thanks = User.current.sent_thanks
    @points = @thanks.stats
    @paginate, @thanks = paginate @thanks.order(created_at: :desc), per_page: 20
  end

  def received
    @thanks = User.current.received_thanks
    @points = @thanks.stats
    @paginate, @thanks = paginate @thanks.order(created_at: :desc), per_page: 20
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
end
