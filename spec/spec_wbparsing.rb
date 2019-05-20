require_relative 'spec_helper'
require_relative "../parsing_scripts/account"
require_relative "../parsing_scripts/wb_parser"

describe WBParser do 

  let(:nokogiri) {Nokogiri::HTML}
  let(:get_account_data) {nokogiri.fragment(File.read("fixtures/account_data.html"))}
  let(:get_transactions_data) {nokogiri.fragment(File.read("fixtures/operations.html"))}


  describe "#get_account_hash" do
    it "get account information hash" do
      expect(subject.send(:get_account_hash, get_account_data)).to eq ({
        :username => "Anastasia Monosienco",
        :balance  => 1349.0,
        :currency => "MDL"
      })
    end
  end

  describe "#get_transactions_array" do
    it "get transactions information hash" do
      expect(subject.send(:get_transactions_array, get_transactions_data)).to include ({
        :date => "14 mar. mai 2019 12:37",
        :description => "Plata retail SUPERMARKET NR 1 CHISINAU Moldova, Rep. Of",  
        :amount => 36.07
      })
    end
  end

end