
class Account

  def initialize(user_name, balance, currency)
    @user_name = user_name
    @balance = balance
    @currency = currency
  end

  def get_account_info
    {:name => @user_name, :balance => @balance, :currency => @currency}
  end

end