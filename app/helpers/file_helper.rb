module FileHelper

  def cleanup_temp_files(filenames)
    filenames.each do |local_filepath|
      next if local_filepath.blank?
      File.delete(local_filepath) if File.exist?(local_filepath)
    end
  end

  def split_file_into_parts(filename)
    stdout, stderr, status =
      Open3
        .capture3("split --verbose -b1K #{filename} #{filename}.split -da 4")

    if !status.success?
      raise stderr
    end
    split_files = stdout.split(/\n/).map { |l| l.gsub('creating file ', '') }
  end

end
