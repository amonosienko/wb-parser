require_relative 'account'
require_relative 'transaction'
require 'pry'
require 'watir'
require 'nokogiri'
require 'json'
require 'neatjson'


class WBParser
  
  WBLINK = 'https://wb.micb.md/'
    
  def initialize
    @transactions = []
  end

  def parse
    autentificate

    account = Account.new(get_user_name, get_account_balace, get_account_currency)

    get_transactions_histoty

    parsed_info = {:account => account.get_account_info, :transactions => @transactions}

    generate_json(parsed_info)
  end

  def browser
    @browser ||= Watir::Browser.new :chrome
  end

  def autentificate    
    browser.goto(WBLINK)

    credentials = JSON.parse(open("credentials.json").read)

    browser.text_field(class: "username").set(credentials[0]["login"])
    browser.text_field(id:"password").set(credentials[0]['password'])
    browser.element(:css => "button[type='submit'][class='wb-button']").click
  end

  def get_user_name
    Nokogiri::HTML.fragment(browser.div(class: "has-last-entry").html).css("span.user-name").text
  end

  def get_account_balace
    Nokogiri::HTML.fragment(browser.div(class: "primary-balance").html).css("span")[0].text.to_f
  end

  def get_account_currency
    Nokogiri::HTML.fragment(browser.div(class: "primary-balance").html).css("span")[1].text
  end
  
  def get_transactions_histoty
    browser.li(class: "tr_history-menu-item").click

    extract_data
  end
 
  def get_html
    browser.div(class: "day-header").wait_until(&:present?)

    Nokogiri::HTML.fragment(browser.div(class: "operations").html)
  end

  def get_transaction_day (html, index)
    html.css("div")[index].text
  end

  def extract_data
    html = get_html
    div_tags = html.search("div")   

    month_year = ""

    div_tags.each.with_index do |value, index|
      if html.css("div")[index]["class"] == "month-delimiter" 
        month_year = html.css("div")[index].text    
      elsif html.css("div")[index]["class"] == "day-operations" 
        transactions_info = html.css("div")[index].css("ul[class='operations-list'] li")

        transactions_info.each do |transact|
          time = transact.css("span[class='history-item-time']").text
          description = transact.css("span[class='history-item-description']").css("a[class='operation-details']").text
          amount = transact.css("span")[4].css("span[class='amount']").text  
          date_time = get_transaction_day(html, index+1) + " " + month_year + " " + time
          curent_transaction = Transaction.new(date_time, description, amount) 
          @transactions << curent_transaction.get_transaction_info
        end   
      end
    end
  end

  def generate_json(p_hash)
    file = File.open('output.json','w')
    file.write(JSON.neat_generate(p_hash, indent:"  ", wrap:60, aligned:true, after_colon_n:1))
    file.close
  end
end
