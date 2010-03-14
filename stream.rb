#!/opt/local/bin/ruby1.9
# -*- coding: utf-8 -*-

require 'uri'
require 'net/http'
require 'yaml'
require 'json'
require "word2id"
require "doc2id"
require "tweet"
require "index_queue"

config = YAML.load_file("config.yaml")

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
      puts "#{i}: #{Tweet.new(status).text}"
      index_queue.add(Tweet.new(status))
      i += 1
    end
  end
end

index_queue.close
word2id.close
doc2id.close
