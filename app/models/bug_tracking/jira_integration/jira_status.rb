class JiraStatus < ActiveRecord::Base
  if ImportSource.find_by_name("Jira connection") and ImportSource.find_by_name("Jira connection").adapter=~/oracle/
    UPPER = false
  else
    UPPER = true
  end
  ID = (UPPER)? 'ID' : 'id'

  self.table_name = 'issuestatus'
  self.primary_key = ID

  has_many :issues, :class_name => 'JiraIssue', :foreign_key => 'issuestatus'

  def value
    self.pname
  end

  def value=(val)
    self.pname = val
  end
end
