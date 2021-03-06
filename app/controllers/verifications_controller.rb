class VerificationsController < ApplicationController
  before_action :require_login, only: [:new]

  def new
    redirect_to :back, notice: "You have to set your phone number first" if current_user.phone.nil?
    verification = current_user.verification_methods.build(name: "sms")
    verification.generate_sms_token
    if verification.save
      client = Twilio::REST::Client.new
      client.messages.create(from: "+447481340112", to: current_user.phone, body: t("sms_verification", code: verification.token))
    else
      redirect_to profile_path, notice: t('verification_exists')
    end
  end

  def create
    verification = current_user.verification_methods.where(name: "sms", token: params[:verification_method][:token])
    if verification.exists?
      verification.update(verified_at: DateTime.now)
      redirect_to profile_path, notice: "Your mobile number has been verified"
    else
      flash['notice']= 'The code you have entered is incorrect'
      render 'verifications/new'
    end
  end

  def update
    verification = VerificationMethod.where(token: params[:token], name: params[:name], verified_at: nil)
    if verification.exists?
      verification.update(verified_at: DateTime.now)
      redirect_to root_path, notice: "Your email address has been verified"
    else
      redirect_to root_path, notice: "Something went wrong"
    end
  end
end
