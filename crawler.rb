require "rubygems"
require "uri"
require "mechanize"
require "hpricot"

# class for crawlering the web using breath first search
class Crawler
  attr_accessor :page, :agent, :visited
  def initialize
    @page = nil
    @agent = WWW::Mechanize.new
    @visited = Set.new
  end
  def crawl(url)
    links = Array.new
    begin
      @page = @agent.get(url)
    rescue Exception => e
      puts e
      return
    end
    source = Hpricot(@page.body)
    (source/"a").each{|item|
      link = item["href"]
      next if link.nil?
      unless link =~ /^http/ # relative path => absolute path
        begin
          link = URI.join(@agent.page.uri.to_s, link).to_s
        rescue Exception => e
          puts e
          next
        end
      end
      links.push link if @visited.add?(link)
    }
    return links
  end
end

