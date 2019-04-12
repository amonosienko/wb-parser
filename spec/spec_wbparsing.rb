require_relative 'spec_helper'
require_relative "../parsing_scripts/account"
require_relative "../parsing_scripts/wb_parser"

describe WBParser do 

  let(:nokogiri) {Nokogiri::HTML}
  let(:get_user_name) {nokogiri.fragment(File.read("fixtures/username.html"))}
  let(:get_account_description) {nokogiri.fragment(File.read("fixtures/account_description.html"))}

  describe Account do
    subject { Account.new(:browser) }

    before do
      allow(subject).to receive(:get_user_name) { get_user_name }
      allow(subject).to receive(:get_account_description) { get_account_description }
    end 

    describe "#get_account_hash" do
      it "get user name" do
        expect(subject.send(:get_account_hash)).to match({
          name: String,
          balance: Float,
          currency:  String
        })
      end
    end
  end
  
end

