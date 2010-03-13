# -*- coding: utf-8 -*-

require "repository"
require "page_queue"
require "crawler"

queue = PageQueue.new
queue.add("http://twitter.com/syou6162")
queue.add("http://twitter.com/mamoruk")
queue.add("http://twitter.com/tkf")
queue.add("http://twitter.com/sesejun")
queue.add("http://twitter.com/mrkn")
queue.add("http://twitter.com/y_benjo")
queue.add("http://twitter.com/totte")
queue.add("http://twitter.com/hyuki")
queue.add("http://twitter.com/bonohu")
queue.add("http://twitter.com/yag_ays")
queue.add("http://twitter.com/mickey24")
queue.add("http://twitter.com/T_Hash")
queue.add("http://twitter.com/wakuteka")

repository = Repository.new("data.db")

n = 10
crawlers = Array.new
n.times{|i|
  crawlers.push Crawler.new
}

exclusive_list = ["", "login", "signup", "about", "goodies", "jobs"]
exclusive_list = exclusive_list.map{|item| item = "http://twitter.com/#{item}"}

t = []
num_of_index = 0
max = 10000
n.times{|i|
  t.push Thread.start{
    while queue.next && num_of_index < max
      url = queue.get
      crawler = crawlers[i]
      puts "#{num_of_index}\t#{i}\t#{url}"
      result = crawler.crawl(url)
      repository.save(url, crawler.page.body) if !crawler.page.nil?
      next if result.nil? # no links in this page
      result.each{|url|
        if url =~ /http:\/\/twitter\.com\/[a-zA-Z0-9_]*$/
          queue.add(url) if exclusive_list.index(url).nil?
        end
      }
      num_of_index += 1
    end
  }
}

t.map{|t|t.join}

repository.close
