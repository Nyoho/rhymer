#!/bin/sh

zcat union.csv.gz | cut -d ',' -f 1,5,6,11 | ruby create-db.rb
