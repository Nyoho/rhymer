#!/usr/bin/env ruby

require 'pg'

class String
  def dajare
    prefix = self
    tr!('ぁ-ん','ァ-ン')

    result = ''
    begin
      host = ENV['DATABASE_HOST'] || 'db'
      database = ENV['DATABASE_NAME'] || 'sinatra'
      username = ENV['DATABASE_USER'] || 'sinatra'
      password = ENV['DATABASE_PASSWORD'] || 'sinatra'

      conn = PG::connect host: host, dbname: database, user: username, password: password
      res = conn.exec %Q|select * from Words where reading like '#{conn.escape_string(prefix)}%'|
      result = res.select{|h| h['partofspeech2'] == "名詞" }
                 .map{|h| h['entry']}
                 .uniq.sample || prefix.tr('ァ-ン','ぁ-ん')
    rescue PG::Error => e
      puts 'Error:'
      puts e.message
      result = prefix.tr('ァ-ン','ぁ-ん')
    ensure
      conn.close if conn
    end
    result
  end
end
