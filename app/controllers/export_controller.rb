require 'odf-report'
class ExportController < ApplicationController
  CASES_TEMPLATE_FN = 'cases.odt'
  RESULTS_TEMPLATE_FN = 'results.odt'
  def export_items
    @template_path = Rails.public_path + "/reports/#{@project.id}"
    @report_path = Rails.public_path + "/reports"
    FileUtils.mkdir_p  @report_path, :verbose =>true unless File.exists? @report_path
    item_type = params[:type]
    id = params[:ids]
    name = 'exported document'
    case item_type
    when 'Case'
      filename = CASES_TEMPLATE_FN
      c = Case.find id
      export_cases [c]
    when 'Execution'
      filename = RESULTS_TEMPLATE_FN
      e = Execution.find id
      cases = Case.find(e.case_executions.collect(&:case_id))
      export_cases_with_results e
    when 'Tag'
      filename = CASES_TEMPLATE_FN
      tag = Tag.find id
      cases = Case.find_with_tags([tag], { :project => @project })
      export_cases cases
    when 'TestSet'
      filename = CASES_TEMPLATE_FN
      ts = TestSet.find id
      cases = ts.cases
      export_cases cases
    end
    begin
      @report.generate("#{@report_path}")
    rescue
      raise "Problem creating report from #{filename}. Try reloading template."
    end
    render :json => {:data => {:path => "reports/#{filename}"}}
  end

  private 

  def export_cases cases
    puts '!!!!!!!!'
    puts "#{@template_path}/#{CASES_TEMPLATE_FN}"
    raise "#{CASES_TEMPLATE_FN} template not found. You can create it from Tools > Import" unless File.exists? "#{@template_path}/#{CASES_TEMPLATE_FN}" 
    @report = ODFReport::Report.new("#{@template_path}/#{CASES_TEMPLATE_FN}") do |r|
      r.add_section("CASES", cases) do |s|
        s.add_field(:test_tags){|item| item.tags_to_s }
        s.add_field(:test_title){|item| @i = 0; item.title.to_s }
        s.add_field :test_objective, :objective
        s.add_field :test_preconditions, :preconditions_and_assumptions
        s.add_field :test_data, :test_data
        s.add_table("STEPS", :steps, :header => true) do |t|
          t.add_column(:step_index){ |item| (@i += 1).to_s }
          t.add_column :step_action, :action
          t.add_column :step_result, :result
        end
      end
    end
  end

  def export_cases_with_results execution
    raise "#{RESULTS_TEMPLATE_FN} template not found. You can create it from Tools > Import" unless File.exists? "#{@template_path}/#{RESULTS_TEMPLATE_FN}"
    @report = ODFReport::Report.new("#{@template_path}/#{RESULTS_TEMPLATE_FN}") do |r|
      r.add_section("CASES", execution.case_executions) do |s|
        s.add_field(:test_tags){|item| item.test_case.tags_to_s }
        s.add_field(:test_title){|item| item.test_case.title.to_s}
        s.add_field(:test_objective){|item| item.test_case.objective}
        s.add_field(:test_preconditions){|item| item.test_case.preconditions_and_assumptions}
        s.add_field(:test_data){|item| item.test_case.test_data}
        s.add_table("STEPS", :step_executions, :header => true) do |t|
          t.add_column :step_index, :position
          t.add_column(:step_action){|item| item.step.action}
          t.add_column(:step_result){|item| item.step.result}
          t.add_column :execution_result, :result
          t.add_column :execution_comment, :comment
        end
      end
    end
  end
end
