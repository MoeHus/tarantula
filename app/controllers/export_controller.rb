require 'odf-report'
class ExportController < ApplicationController

  def export_items
    @template_path = Rails.public_path + "/reports/#{@project.id}"
    @report_path = Rails.public_path + "/reports"
    item_type = params[:type]
    id = params[:ids]
    name = 'exported document'
    case item_type
    when 'Case'
      filename = 'cases.odt'
      c = Case.find id
      export_cases [c]
    when 'Execution'
      filename = 'results.odt'
      e = Execution.find id
      cases = Case.find(e.case_executions.collect(&:case_id))
      export_cases_with_results e
    when 'Tag'
      filename = 'cases.odt'
      tag = Tag.find id
      cases = Case.find_with_tags([tag], { :project => @project })
      export_cases cases
    when 'TestSet'
      filename = 'cases.odt'
      ts = TestSet.find id
      cases = ts.cases
      export_cases cases
    end
    @report.generate(@report_path)
    render :json => {:data => {:path => "reports/#{filename}"}}
  end

  private 

  def export_cases cases
    @report = ODFReport::Report.new("#{@template_path}/cases.odt") do |r|
      r.add_section("CASES", cases) do |s|
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
    @report = ODFReport::Report.new("#{@template_path}/results.odt") do |r|
      r.add_section("CASES", execution.case_executions) do |s|
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
