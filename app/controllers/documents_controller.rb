class DocumentsController < ApplicationController
  include ApplicationHelper
  include DocumentsHelper

  before_action :authorized, except: :download

  def index
    @documents = current_user.documents.all
  end

  def new
    @document = Document.new
  end

  def create
    @document = current_user.documents.new
    document_params = params[:document]
    @document.title = document_params[:title]
    @document.description = document_params[:description]
    input_file = document_params[:file]
    input_file_name = input_file.original_filename
    @document.file = input_file_name

    input_file_dir = Rails.root.join(path_to_file_dir)

    if @document.valid?

      if @document.save
        Dir.mkdir('uploads') unless Dir.exist?('uploads')
        Dir.mkdir(input_file_dir) unless Dir.exist?(input_file_dir)
        File.open(Rails.root.join(path_to_file(input_file_name)), 'wb') do |file|
          file.write(input_file.read)
        end
        redirect_to documents_url, notice: 'File uploaded successfully!'
      else
        render :new, status: :unprocessable_entity
      end

    else
      render :new, status: :unprocessable_entity, notice: 'File already exists'
    end
  end

  def edit
    @document = Document.new(documents_params)
  end

  def update; end

  def download
    send_file path_to_file(Rails.root.join('uploads', params[:id], params[:file])), x_sendfile: true
  end

  def destroy
    @document = current_user.documents.find(params[:id])
    file_name = @document.file
    File.delete(path_to_file(file_name)) if File.exist?(path_to_file)
    if @document.destroy
      redirect_to documents_url, notice: 'File deleted successfully!'
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def documents_params
    @params.require(:documents).permit(:title, :description)
  end
end
