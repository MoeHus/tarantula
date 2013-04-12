# encoding: UTF-8
class Sentence < ActiveRecord::Base
	attr_accessible :project, :value
 	belongs_to :project
 	validates_presence_of :value
 	validates_uniqueness_of :value, :scope => :project_id

  @@lang = 'en'

  def self.lang= l
    @@lang = l
  end

  def self.lang
    @@lang
  end

  def self.strip(str)
    if str =~ /^([^:]+):.*$/ and Sentence.keywords.include? $1
      return "#{$1}:"
    elsif str =~ /"[^"]*"/
      str.gsub(/"[^"]*"/,'""').chomp
    elsif str =~ /\[[^\[]*\]/
      str.gsub(/\[[^\[]*\]/,'""').chomp
    end
  end

  def self.keywords 
    keywords = {}
    kw_dirty = JSON.parse(File.open(Rails.public_path + '/cucumber.json').read)[@@lang]
    kw_dirty.each{ |val, tran| keywords[val] = tran.split("|").first if tran =~ /|/ }
    keywords
  end

  def self.allowed?(s)
    return true if s =~ /^\s*[#|].+/
    false
  end

  def self.prepare s
    s.gsub("[",'"<').gsub("]",'>"').chomp
    out = s
    first_word = s.scan(/\s*[^\s]+/).first.gsub(":","")
    out = "* #{s}" unless Sentence.keywords.values.include?(first_word) or s =~ /^\s*#/
    out
  end

end
