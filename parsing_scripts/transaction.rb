require 'pry'
require 'nokogiri'
require 'open-uri'


class Transaction

  def initialize(date, description, ammount)
    @date = date
    @description = description
    @ammount = ammount 
  end

  def get_transaction_info
    {:date => @date, :description => @description, :ammount => @ammount}
  end
end