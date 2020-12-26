#!/usr/bin/env ruby

require './select-word.rb'
require 'benchmark'

Benchmark.bm 10 do |r|
  r.report "String.dajare" do
    100.times do 
      'ます'.dajare
    end
  end
end

Benchmark.bm 10 do |r|
  r.report "PostgreSQL select" do
    host = ENV['DATABASE_HOST'] || 'db'
    database = ENV['DATABASE_NAME'] || 'sinatra'
    username = ENV['DATABASE_USER'] || 'sinatra'
    password = ENV['DATABASE_PASSWORD'] || 'sinatra'
    conn = PG::connect host: host, dbname: database, user: username, password: password

    100.times do
      ['マス', 'テネ'].each do |s|
        res = conn.exec %Q|select * from Words where reading like '#{conn.escape_string(s)}%'|
      end
    end
  end
end
