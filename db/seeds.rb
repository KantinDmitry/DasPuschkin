# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'json'

verses_file = File.open('verses.json', 'r')
verses_hash = JSON.parse verses_file.read
verses_file.close

verses_hash.each do |title, text|
  title = text[0] if title == '* * *'
  text = text.join("\n")
  title = title.delete " "
  text = text.delete " "
  Verse.create title: title, text: text
end
