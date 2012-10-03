class AutomationController < ApplicationController
  before_filter do |c|
    c.require_permission(:any)
  end

	def execute
		execution = Execution.find(params[:execution])
		project = execution.project
		at = AutomationTool.find(project.automation_tool_id)
		case_execution = CaseExecution.find(params[:testcase_execution])
		tc = case_execution.test_case
		cmd = at.command_pattern.gsub(/\$\{testCase\}/,tc.title).gsub(/\$\{execution\}/, execution.name).gsub(/\$\{project\}/,project.name)
		case_execution.update_attribute(:blocked, true)
    render :json => {:data => {:cmd => cmd}}
	end
end
