#!/opt/local/bin/ruby1.9
# -*- coding: utf-8 -*-
require 'yaml'
require 'json'
require "repository"
require "page_queue"
require "crawler"
require "word2id"
require "doc2id"
require "tweet"
require "index_queue"

config = YAML.load_file("config.yaml")

# @repository = Repository.new("data.db", "pair_of_doc_id_and_word_id")

word2id = Word2ID.new({"host" => config["word2id"]["host"], 
                        "port" => config["word2id"]["port"]})

doc2id = Doc2ID.new({"host" => config["doc2id"]["host"], 
                      "port" => config["doc2id"]["port"]})

index_queue = IndexQueue.new({"word2id" => word2id, "doc2id" => doc2id,
                               "host" => config["word2docs"]["host"], 
                               "port" => config["word2docs"]["port"]})

uri = URI.parse('http://stream.twitter.com/1/statuses/sample.json')

username = config["stream"]["username"]
password = config["stream"]["password"]

i = 0
Net::HTTP.start(uri.host, uri.port) do |http|
  request = Net::HTTP::Get.new(uri.request_uri)
  # Streaming APIはBasic認証のみ
  request.basic_auth(username, password)
  http.request(request) do |response|
    raise 'Response is not chuncked' unless response.chunked?
    response.read_body do |chunk|
      # 空行は無視する = JSON形式でのパースに失敗したら次へ
      status = JSON.parse(chunk) rescue next
      # 削除通知など、'text'パラメータを含まないものは無視して次へ
      next unless status['text']
      user = status['user']
      if user['lang'] == "ja"
        puts Tweet.new(status).text
        index_queue.add(Tweet.new(status))
        # @index_queue.add(Tweet.new("http://twitter.com/#{user['screen_name']}/status/#{status['id']}", status['text'])) 
        puts i
        i += 1
      end
    end
  end
end

index_queue.close
word2id.close
doc2id.close


__END__

queue = PageQueue.new
repository = Repository.new("data.db")

n = 10
crawlers = Array.new
n.times{|i|
  crawlers.push Crawler.new
}

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
