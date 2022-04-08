module DocumentsHelper
  def path_to_file_dir
    Rails.root.join('uploads', session[:user_id].to_s)
  end

  def path_to_file(file_name)
    Rails.root.join(path_to_file_dir, file_name)
  end
end
