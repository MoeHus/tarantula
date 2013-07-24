require 'logger'
class AutomationController < ApplicationController
  before_filter do |c|
    c.require_permission(:any)
  end
	def execute		
		@log = File.new(Rails.public_path+"/at/#{@current_user.login}_#{Time.now.strftime("%Y%m%d_%H_%M")}.html","w+")
		execution = Execution.find(params[:execution])
		project = execution.project
		at = AutomationTool.find(project.automation_tool_id)
		case_execution = CaseExecution.find(params[:testcase_execution])
		tc = case_execution.test_case
		cmd = at.command_pattern.gsub(/\$\{steps\}/,case_execution.step_executions.length.to_s).gsub(/\$\{test\}/,tc.title).gsub(/\$\{execution\}/, execution.name).gsub(/\$\{project\}/,project.name)
		case_execution.update_attribute(:blocked, true)
		Bundler.with_clean_env do
			fork { exec "#{cmd} > #{@log.path} 2>&1" }
		end
		domen = request.protocol+request.host
		domen+=":#{request.port}" if not request.port.nil?
		domen+='/at'
		render :json => {:data => {:message => "#{at.name} started with command\n\'#{cmd}\'\n\nLog can be found here: #{domen}/#{File.basename(@log.path)}"}}
		@log.close
	end

  def get_sentences
    render :json => { :data => @project.sentences.collect(&:value) }
  end
end
