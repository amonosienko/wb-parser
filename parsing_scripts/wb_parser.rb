require_relative 'account'
require_relative 'transaction'
require 'pry'
require 'watir'
require 'nokogiri'
require 'json'
require 'neatjson'


class WBParser
  WBLINK = 'https://wb.micb.md/'
  Transactions = []

  def parse
    autentificate

    account_info = get_account_hash(Nokogiri::HTML.fragment(browser.body(class: "owwb-ls-section").html))
    account = Account.new(account_info[:username], account_info[:balance], account_info[:currency])

    browser.li(class: "tr_history-menu-item").click
    transactions_html = get_html
    get_transactions_array(transactions_html)

    parsed_info = {:account => account.get_account_info, :transactions => Transactions}

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

  def get_account_hash(html)
    {
      :username => html.css("div.has-last-entry span.user-name").text,
      :balance  => html.css("div.primary-balance span")[0].text.sub(".", "").sub(",", ".").to_f,
      :currency => html.css("div.primary-balance span")[1].text
    }
  end

  def get_user_name(html)
    html.css("span.user-name").text
  end

  def get_account_balance(html)
    html.css("span")[0].text.sub(".", "").sub(",", ".").to_f
  end

  def get_account_currency(html)
    html.css("span")[1].text
  end
 
  def get_html
    browser.div(class: "day-header").wait_until(&:present?)

    Nokogiri::HTML.fragment(browser.div(class: "operations").html)
  end

  def get_transaction_day (html, index)
    html.css("div")[index].text.strip
  end

  def get_transactions_array(transactions_html)
    div_tags = transactions_html.search("div")   

    month_year = ""

    div_tags.each.with_index do |value, index|
      if transactions_html.css("div")[index]["class"] == "month-delimiter" 
        month_year = transactions_html.css("div")[index].text.strip
      elsif transactions_html.css("div")[index]["class"] == "day-operations" 
        transactions_info = transactions_html.css("div")[index].css("ul[class='operations-list'] li")

        transactions_info.each do |transact|
          time = transact.css("span[class='history-item-time']").text.strip
          description = transact.css("span[class='history-item-description']").css("a[class='operation-details']").text.gsub(/\s{2,}/,' ')
          amount = transact.css("span")[4].css("span[class='amount']").text.sub(",", ".").to_f 
          date_time = get_transaction_day(transactions_html, index+1) + " " + month_year + " " + time
          curent_transaction = Transaction.new(date_time, description, amount) 
          Transactions << curent_transaction.get_transaction_info
        end
      end
    end
    Transactions
  end

  def generate_json(p_hash)
    file = File.open('output.json','w')
    file.write(JSON.neat_generate(p_hash, indent:"  ", wrap:60, aligned:false, after_colon_n:1))
    file.close
  end
end