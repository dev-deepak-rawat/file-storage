class DocumentsController < ApplicationController
  include ApplicationHelper
  include DocumentsHelper

  before_action :authorized, except: :download

  def index
    @documents = User.get_user_docs_with_permission(current_user, Permission.accesses['owner'])
    @rest_users = User.where.not(id: session[:user_id])
    @shared_documents = User.get_user_docs_with_permission(current_user, Permission.accesses['guest'])
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
        Permission.create(user: current_user, document: @document)
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
    permission = Permission.find_by_user_and_doc_id(session[:user_id], params[:id])
    document = Document.find(params[:id])
    document_owner_id = document.permissions.owner.pluck(:user_id).first
    if document&.public_share || permission
      send_file path_to_file(Rails.root.join(
                               'uploads', document_owner_id.to_s, document[:file]
                             )), x_sendfile: true
    else
      render file: 'public/404.html', status: :unauthorized
    end
  rescue ActiveRecord::RecordNotFound
    render file: 'public/404.html', status: :unauthorized
  end

  def share
    target_document = Document.find(params[:id])
    target_document.update(public_share: !target_document.public_share)
    redirect_to documents_url
  end

  def private_share
    user = User.find(params[:user_id])
    if params[:type] == 'share'
      document = Document.find(params[:id])
      redirect_to documents_url if Permission.create(user: user, document: document, access: :guest)
    else
      Permission.find_by_user_and_doc_id(params[:user_id], params[:id]).destroy
      redirect_to documents_url
    end
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
