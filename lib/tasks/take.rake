namespace :scrape do
  desc "Task Description Here"

  task :noko => :environment do
    require 'open-uri'
    require 'watir-webdriver'

    url = "http://9gag.tv/?ref=9nav"

    browser = Watir::Browser.new :phantomjs

    browser.goto url

    2.times do |i|
      puts i
      browser.send_keys :space
      sleep 10
    end

    # document = open(url).read

    html_doc = Nokogiri::HTML(browser.html)

    puts html_doc

    youtube_url = []

    html_doc.css('div > div.item.twoColumn-left.clearfix > div.info > a.title').each do |anchor|

      document2 = open(anchor.attr("href")).read

      html_doc2 = Nokogiri::HTML(document2)

      youtube_url.push(html_doc2.css("#jsid-post-container").attr("data-external-id"))

      puts html_doc2.css("#jsid-post-container").attr("data-external-id")
    end
    # puts youtube_url
  end

  task :noko2 => :environment do
    require 'open-uri'

    url = "http://9gag.tv/?ref=9nav"

    document = open(url).read

    html_doc = Nokogiri::HTML(document)


    html_doc.css('div > div.item.twoColumn-left.clearfix > div.info > a.title').each do |anchor|

      document2 = open(anchor.attr("href")).read

      html_doc2 = Nokogiri::HTML(document2)

      puts html_doc2.css("#jsid-post-container").attr("data-external-id")
    end
  end

  task :company => :environment do
    require 'open-uri'
    require 'csv'

    url = "http://s3.amazonaws.com/nvest/nasdaq_09_11_2014.csv"

    url_data = open(url)

    # document = CSV.read(url_data)[1..-1]

    # document.each_with_index do |company|
    #   puts compnay[0]
    # end

    CSV.foreach(url_data) do |symbol, name|
      puts "#{name}: #{symbol}"
      Company.create(:name => name, :symbol => symbol.delete(' '))
    end
  end

  #------------------------------------------------------------------------------------------------------------
  task :record_data => :environment do
    Company.all.each do |company|
      record_data(company)
    end
  end

  def record_data(company)
    require 'open-uri'
    require 'nokogiri'

    url = "http://www.google.ca/finance?q="+company.symbol.upcase+"&fstype=ii"

    document = open(url).read
    html_doc = Nokogiri::HTML(document)

    # columns 
    puts html_doc.css("div.id-incannualdiv > table.gf-table.rgt > tbody > tr > td.lft.lm").text
    puts html_doc.css("div.id-incannualdiv > table.gf-table.rgt > tbody > tr > td:nth-child(2).r").text
    puts html_doc.css("div.id-incannualdiv > table.gf-table.rgt > tbody > tr > td:nth-child(3).r").text
    puts html_doc.css("div.id-incannualdiv > table.gf-table.rgt > tbody > tr > td:nth-child(4).r").text
    puts html_doc.css("div.id-incannualdiv > table.gf-table.rgt > tbody > tr > td.r.rm").text

    details = html_doc.css("div.id-incannualdiv > table.gf-table.rgt > tbody > tr > td.r.rm")

    if not details.any?
      return
    end

    new_record = company.annual_incomes.new

    AnnualIncome.columns[4..52].each_with_index do |column, index|
      new_record["#{column.name}"] = details[index].text
    end
    new_record.save
  end
end