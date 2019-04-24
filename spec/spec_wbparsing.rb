require_relative 'spec_helper'
require_relative "../parsing_scripts/account"
require_relative "../parsing_scripts/wb_parser"

describe WBParser do 

  let(:nokogiri) {Nokogiri::HTML}
  let(:get_user_name) {nokogiri.fragment(File.read("fixtures/username.html"))}
  let(:get_account_balance) {nokogiri.fragment(File.read("fixtures/account_description.html"))}
  let(:get_account_currency) {nokogiri.fragment(File.read("fixtures/account_description.html"))}
  
  describe "#get_user_name" do
    it "get account username" do
      expect(subject.send(:get_user_name, get_user_name)).to eq "Anastasia Monosienco"
    end
  end

  describe "#get_account_balance" do
    it "get account balace" do
      expect(subject.send(:get_account_balance, get_account_balance)).to eq 489
    end
  end

  describe "#get_account_currency" do
    it "get account currency" do
      expect(subject.send(:get_account_currency, get_account_currency)).to eq "MDL"
    end
  end

end