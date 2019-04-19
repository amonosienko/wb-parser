
class Transaction

  def initialize(date, description, amount)
    @date = date
    @description = description
    @amount = amount 
  end

  def get_transaction_info
    { :date => @date, :description => @description, :amount => @amount }
  end
end