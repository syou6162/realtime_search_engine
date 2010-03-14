# -*- coding: utf-8 -*-
require 'tokyocabinet'

class Doc2ID
  attr_accessor :doc2id, :id2doc
  def initialize(opts)
    @doc2id = Hash.new
    @id2doc = Array.new
    @hdb = TokyoCabinet::HDB.new # ハッシュデータベースを指定
    @hdb.open(opts["hdb_name"], opts["mode"])

    # traverse records
    @hdb.iterinit
    while doc = @hdb.iternext
      doc = doc.force_encoding('UTF-8')
      id = @hdb.get(doc).to_i
      @doc2id[doc] = id
      @id2doc[id] = doc
    end
  end
  def getID(doc, modify = true)
    if !@doc2id.key?(doc) && modify
      @doc2id[doc] = @doc2id.size
      @id2doc.push doc
      # @hdb.put(doc, @doc2id[doc])
      @hdb.putasync(doc, @doc2id[doc])
    end
    return @doc2id[doc]
  end
  def [](doc_id)
    return @id2doc[doc_id]
  end
  def close
    @hdb.close
  end
end
