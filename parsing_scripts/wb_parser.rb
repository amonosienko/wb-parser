require_relative 'account'
require_relative 'transactions'
require 'pry'
require 'watir'
require 'json'
require 'json/pure'

class WBParser
  
  @@wb_link = 'https://wb.micb.md/'
  
  def parse
    autentificate
    account = Account.new(browser)
    transactions = Transactions.new(browser)
    parsed_info = {:account => account.get_account_info, :transactions => transactions.get_transactions_info}
    generate_json(parsed_info)
  end

  def browser
    @browser ||= Watir::Browser.new :chrome
  end

  def autentificate    
    browser.goto(@@wb_link)

    secret_data = open(".env.json").read
    no_secrets = JSON.parse(secret_data)

    browser.text_field(class:'username').set(no_secrets[0]["login"])
    browser.text_field(id: 'password').set(no_secrets[0]["password"])
    browser.element(:css => 'button[type=submit][class=wb-button]').click
  end

  def generate_json(p_hash)
    file = File.open('output.json','w')
    file.write(JSON.pretty_generate(p_hash))
    file.close
  end

end