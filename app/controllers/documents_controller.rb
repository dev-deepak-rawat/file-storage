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
    @document = Document.find(params[:id])
  end

  def update
    @document = current_user.documents.find(params[:id])
    update_params = documents_params
    old_file_name = update_params[:file]
    file_extension = File.extname(old_file_name)
    update_params[:file] = "#{update_params[:title]}#{file_extension}"

    File.open(path_to_file(old_file_name)) do |file|
      File.rename(file, path_to_file(update_params[:file]))
    end

    if @document.update(update_params)
      redirect_to documents_url, notice: 'File updated successfully!'
    else
      render :edit, status: :unprocessable_entity, notice: 'Something went wrong'
    end
  end

  def download
    target_document = Document.find(params[:id])
    if target_document && (
      target_document.public_share || target_document.user_id == session[:user_id]
    )
      send_file path_to_file(Rails.root.join(
                               'uploads', target_document.user_id.to_s, target_document[:file]
                             )), x_sendfile: true
    else
      render file: 'public/404.html', status: :unauthorized
    end
  end

  def share
    target_document = Document.find(params[:id])
    target_document.update(public_share: !target_document.public_share)
    redirect_to documents_url
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
    params.require(:document).permit(:title, :description, :file, :id)
  end
end
