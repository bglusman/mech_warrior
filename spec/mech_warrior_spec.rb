require 'spec_helper'

module MechWarrior
  describe Crawler do

    before(:each) do
      FakeWeb.clean_registry
    end

    describe "crawl" do

      context "crawl all the html pages in a domain by following <a> href's" do
        let(:pages) do
          pages = []
          pages << FakePage.new('0', links: ['1', '2'])
          pages << FakePage.new('1', links: ['3'])
          pages << FakePage.new('2')
          pages << FakePage.new('3')
          pages
        end

        subject { Crawler.new(start_url:    pages[0].url,
                              logger_class: String,
                              output_file:  "")
                }

        it {should have(4).pages }
        its(:logger) {should be_empty }
      end

      context "should not follow links that leave the original domain" do
        let(:pages) do
          pages = []
          pages << FakePage.new('0', links: ['1'], :hrefs => 'http://www.other.com/')
          pages << FakePage.new('1')
          pages
        end

        subject { Crawler.new(start_url:    pages[0].url,
                              logger_class: String,
                              output_file:  "")
                }
        it { should have(2).pages }
        its("pages.keys") { should_not include('http://www.other.com/') }
        its(:logger) {should be_empty }
      end

      context "should not index non-html links" do
        let(:pages) do
          pages = []
          pages << FakePage.new('0', links: ['1', '2'])
          pages << FakePage.new('1', content_type: 'application/pdf')
          pages << FakePage.new('2', content_type: 'text/csv')
          pages
        end

        subject { Crawler.new(start_url:    pages[0].url,
                              logger_class: String,
                              output_file:  "")
                }
        it { should have(1).pages }
        its(:logger) {should be_empty }
      end

      context "should ignore invalid URLs" do
        let(:pages) do
          pages = []
          pages << FakePage.new('0', links: ['1', '2'])
          pages << FakePage.new('1', links: ['not a valid url'])
          pages << FakePage.new('2')
          pages << FakePage.new('not_a_valid_url')
          pages
        end

        subject { Crawler.new(start_url:    pages[0].url,
                              logger_class: String,
                              output_file:  "")
                }
        it { should have(3).pages }
        its(:logger) {should_not be_empty }
      end

    end
  end
end
