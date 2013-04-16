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
    if str =~ /^(.+:)\s*.+$/
      str = $1
    end
    if str =~ /"[^"]*"/
      str = str.gsub(/"[^"]*"/,'""').chomp
    end
    if str =~ /\[[^\[]*\]/
      str = str.gsub(/\[[^\[]*\]/,'""').chomp
    end

    return str
  end

  def self.keywords 
    keywords = {}
    kw_dirty = JSON.parse(File.open(Rails.public_path + '/cucumber.json').read)[@@lang]
    kw_dirty.each{ |val, tran| keywords[val] = tran.split("|").first if tran =~ /|/ }
    keywords
  end

  def self.allowed?(s)
    return true if s =~ /^\s*[#|].+/
    return true if s =~ /^\s*$/
    false
  end

  def self.prepare s
    keyword_candidate = ''
    if s =~ /^([^:]+):/
      keyword_candidate = $1
    end
    s = s.gsub("[",'"<').gsub("]",'>"').chomp
    if Sentence.allowed?(s) or Sentence.keywords.include?(keyword_candidate)
      return s
    else
      return '* '+s
    end
  end

end
