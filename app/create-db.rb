#!/usr/bin/env ruby
# coding: utf-8

require 'csv'
require 'pg'

def main
  begin
    host = ENV['DATABASE_HOST'] || 'db'
    database = ENV['DATABASE_NAME'] || 'sinatra'
    username = ENV['DATABASE_USER'] || 'sinatra'
    password = ENV['DATABASE_PASSWORD'] || 'sinatra'

    conn = PG::connect host: host, dbname: database, user: username, password: password

    conn.exec (<<END_SQL)
DROP TABLE IF EXISTS Words;
CREATE TABLE Words (Entry TEXT, Reading TEXT, Partofspeech TEXT, Partofspeech2 TEXT );
END_SQL

    n = 0
    conn.copy_data "COPY Words (Entry, Partofspeech2, Partofspeech, Reading) FROM STDIN WITH CSV" do
      while line = STDIN.gets
        print "\r#{n}: #{line.strip}\033[K" if n % 10000 == 0
        conn.put_copy_data line
        n += 1
      end
    end

    result = conn.exec "SELECT COUNT(*) AS count FROM Words"
    puts result[0]['count']
    
  rescue PG::Error => e
    puts 'Error:'
    puts e.message
  ensure
    conn.close if conn
  end
end

main
