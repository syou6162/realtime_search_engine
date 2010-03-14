# -*- coding: utf-8 -*-

require 'tokyotyrant'
class InvertedIndex
  def initialize(opts)
    @rdb = TokyoTyrant::RDB::new
    if !@rdb.open(opts["host"], opts["port"])
      ecode = @rdb.ecode
      STDERR.printf("open error: %s\n", @rdb.errmsg(ecode))
    end 

    @word2id = opts["word2id"]
    @doc2id = opts["doc2id"]
  end
  def getDocs(word)
    result = []
    word.chars.each_cons(2).each{|item|
      sub_result = []
      tmp = @rdb.get(@word2id.getID(item.join))
      if !tmp.nil?
        tmp.unpack('C*').each{|doc_id| # バイナリを配列に
          sub_result.push doc_id
        }
      end
      result.push sub_result
    }

    return result.inject{|intersection, doc_id| 
      intersection & doc_id
    }.uniq
  end
  def close
    @rdb.close
  end
end
