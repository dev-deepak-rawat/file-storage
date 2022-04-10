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
    input_file_extension = File.extname(input_file.original_filename)
    @document.file = "#{@document.title}#{input_file_extension}"

    input_file_dir = Rails.root.join(path_to_file_dir)

    if @document.valid?

      if @document.save
        Dir.mkdir('uploads') unless Dir.exist?('uploads')
        Dir.mkdir(input_file_dir) unless Dir.exist?(input_file_dir)
        File.open(Rails.root.join(path_to_file(@document.file)), 'wb') do |file|
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

  def update
    update_params = documents_params
    file_extension = File.extname(update_params[:file])
    update_params[:file] = "#{update_params[:title]}#{file_extension}"
    if Document.update(update_params)
      redirect_to documents_url, notice: 'File updated successfully!'
    else
      render :edit, status: :unprocessable_entity, notice: 'Something went wrong'
    end
  end

  def download
    send_file path_to_file(Rails.root.join('uploads', params[:id], params[:file])), x_sendfile: true
  end

  def destroy
    @document = current_user.documents.find(params[:id])
    file_name = @document.file
    File.delete(path_to_file(file_name)) if File.exist?(path_to_file_dir)
    if @document.destroy
      redirect_to documents_url, notice: 'File deleted successfully!'
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def documents_params
    params.permit(:title, :description, :file, :id)
  end
end
