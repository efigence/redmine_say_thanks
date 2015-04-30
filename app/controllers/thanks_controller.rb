class ThanksController < ApplicationController
  unloadable

  before_action :permitted?

  def index
  end

  def create
  end

  def destroy
  end

  private

  def permitted?
    deny_access unless User.current.can_access_thanks?
  end
end
