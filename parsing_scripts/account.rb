require 'pry'
require 'nokogiri'
require 'open-uri'

class Account
  
  def initialize (browser)
    @browser = browser
  end 

  def get_account_info
    account_hash = {}
    account_hash = get_account_hash
    account_hash
  end

  def get_account_hash
    { 
      name: get_user_name.css("span.user-name").text,
      balance: get_account_description.css("span")[0].text.to_f,
      currency: get_account_description.css("span")[1].text
    }
  end  

  def get_user_name
    Nokogiri::HTML.fragment(@browser.div(class: "has-last-entry").html)
  end

  def get_account_description
    Nokogiri::HTML.fragment(@browser.div(class: "primary-balance").html)
  end

end