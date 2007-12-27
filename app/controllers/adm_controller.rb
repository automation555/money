class AdmController < ApplicationController

  TXN_LIMIT=TxnController::TXN_LIMIT

  def index
    title "Reset a user's password"
  end

  def reset_password
    user=User.find_by_login params[:user]
    user.salt = Digest::SHA1.hexdigest("--#{Time.now.to_s}--#{user.login}--")
    @newpass = gen_pw
    user.password = @newpass
    user.password_confirmation = @newpass
    user.save!
    title "Changed #{user.login}'s password"
  end

  def recent
    @transactions=MoneyTransaction.find_with_deleted :all,
      :order => "id desc", :limit => TXN_LIMIT
    title "Recent Transactions"
  end

  def delete
    @txn = MoneyTransaction.find params[:id]
    @txn.destroy
  end

  def undelete
    @txn = MoneyTransaction.find_with_deleted params[:id]
    @txn.deleted_at = nil
    @txn.save!
  end

  protected

  def gen_pw
    # This is a dumb password generator, but it generates 8 lowercase letters.
    (1..8).map{|x| (97 + rand(26)).chr}.join
  end

  def authorized?
    current_user.admin?
  end

  def access_denied
    # XXX:  Should probably find a good place for this document.
    render :template => 'report/access_denied'
  end
end
