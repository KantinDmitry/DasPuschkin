# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require 'json'

LineHash.delete_all
Verse.delete_all

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

Verse.all.each do |verse|
  verse.text.split("\n").each do |line|
    letters = line.chars - ['.', ',', ':', ';', ':', '«', '»', '–', '—', '!', '?', '-', '"', '(', ')', ' ']
    letters = letters.sort
    letters = letters.join
    letters_hash = 0
    letters.each_byte { |byte| letters_hash = letters_hash + byte }
    LineHash.create line: line, letters: letters, letters_hash: letters_hash, length: letters.length
  end
end
