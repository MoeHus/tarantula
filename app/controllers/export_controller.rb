require 'odf-report'
class ExportController < ApplicationController

  def export_items
    item_type = params[:type]
    id = params[:ids]
    name = 'exported document'
    case item_type
    when 'Case'
      c = Case.find id
      export_cases [c]
      name = c.title
    when 'Execution'
      e = Execution.find id
      cases = Case.find(e.case_executions.collect(&:case_id))
      puts cases.collect(&:title)
      export_cases cases
      name = e.name
    when 'Tag'
    end
    path = Rails.public_path + "/reports/"
    @report.generate(path)
    render :json => {:data => {:path => '/reports/export.odt'}}
  end

  private 

  def export_cases cases
    @report = ODFReport::Report.new("#{Rails.public_path}/export.odt") do |r|
      r.add_section("CASES", cases) do |s|
        s.add_field(:test_title){|item| item.title}
        s.add_field :test_objective, :objective
        s.add_field :test_preconditions, :preconditions_and_assumptions
        s.add_field :test_data, :test_data
        s.add_table("STEPS", :steps, :header => true) do |t|
          i = 0
          t.add_column(:step_index){ |item| (i += 1).to_s }
          t.add_column :step_action, :action
          t.add_column :step_result, :result
        end
      end
    end
  end
end
