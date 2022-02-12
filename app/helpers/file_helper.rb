module FileHelper

  def cleanup_temp_files(filenames)
    filenames.each do |local_filepath|
      next if local_filepath.blank?
      next if local_filepath == "."
      next if local_filepath == ".."
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
    split_files = stdout.split(/\n/).map { |l| l.gsub('creating file ', '').gsub("'", '') }
  end

  def assemble_file_from_parts(input_filenames)
    output_filename = input_filenames.first.split('.split').first
    stdout, stderr, status =
      Open3
        .capture3("cat #{input_filenames.join(' ')} > #{output_filename}")

    if !status.success?
      raise stderr
    end
    output_filename
  end

end
