require 'pry'
require 'nokogiri'
require 'open-uri'


class Transactions

  def initialize (browser)
   @browser = browser
  end

  def get_transactions_info
    go_to_transactions
    transactions = [] 
    extract_data(transactions)
  end

  def go_to_transactions
    @browser.li(class:"tr_history-menu-item").click
  end
  
  def get_html
    @browser.div(class: "day-header").wait_until(&:present?)
    Nokogiri::HTML.fragment(@browser.div(class:"operations").html)
  end

  def extract_data (transactions)
    @html = get_html
    divs_count = @html.search("div").size
    
    div_index = 1 
    month_year = ""
    time = ""
    date_time = ""
    
    def get_day (index)
      @html.css("div")[index].text
    end

    while div_index < divs_count do
      if @html.css("div")[div_index]["class"] == "month-delimiter" then
        month_year = @html.css("div")[div_index].text    
      elsif @html.css("div")[div_index]["class"] == "day-operations" 
        transactions_info = @html.css("div")[div_index].css("ul[class=operations-list] li")

        transactions_info.each do |transact|
          time = transact.css("span[class=history-item-time]").text
          description = transact.css("span[class=history-item-description]").css("a[class=operation-details]").text
          ammount = transact.css("span")[4].css("span[class=amount]").text  
          date_time = get_day(div_index+1) + " " + month_year + " " + time
          transactions << {:date => date_time, :description => description, :ammount => ammount}
        end   
      end
      div_index += 1
    end
    transactions
  end
end