class JiraRequirement < JiraIssue
  if ImportSource.find_by_name("Jira connection") and ImportSource.find_by_name("Jira connection").adapter=~/oracle/
    UPPER = false
  else
    UPPER = true
  end
  ID = (UPPER)? 'ID' : 'id'
  self.inheritance_column = nil
  default_scope :conditions => "(select pname from issuetype where #{ID} = jiraissue.issuetype) = 'Requirement'"
end
