class PlansController < ApplicationController
  def choose
    plan = Plan.find_by!(slug: params['slug'])
    current_account.update_attributes!(plan: plan)
    flash[:notice] = "Your plan has been saved"

    redirect_to root_path
  end
end