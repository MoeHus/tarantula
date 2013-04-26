class CsvImportsController < ApplicationController
  layout false
  
  def new
  end

  def create
    # TODO: see that stuff isn't imported to wrong project
    @log = ''
    if params[:file] != nil
      import = CsvExchange::Import.new(params[:file], @project.id,
                                       @current_user.id, params[:simulate])
      import.process
      @log += import.log
    end
    if params[:tests_template_file] != nil
      f = create_upload_file(ExportController::CASES_TEMPLATE_FN)
      f.puts params[:tests_template_file].read.force_encoding("utf-8")
      f.close
      @log += '</br><span style="background-color:#77ff77">Tests template file uploaded'
    end
    if params[:results_template_file] != nil
      f = create_upload_file(ExportController::RESULTS_TEMPLATE_FN)
      f.puts params[:results_template_file].read.force_encoding("utf-8")
      f.close
      @log += '</br><span style="background-color:#77ff77">Results template file uploaded'
    end

    render :template => '/import/log'
  end
end

private

  def create_upload_file(name)
    upload_dir = "#{Rails.public_path}/#{@project.id.to_s}"
    FileUtils.mkdir_p  upload_dir, :verbose =>true unless File.exists? upload_dir
    File.new("#{upload_dir}/#{name}", "w+")
  end
