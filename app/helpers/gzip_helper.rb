module GzipHelper

  def gzip_file(filename)
    sanitized_filename = sanitize_filename(filename)
    gzip_filename = sanitized_filename + '.gz'
    puts "Gzipping #{gzip_filename}"
    stdout, stderr, status = Open3.capture3('gzip -cvf ' + sanitized_filename + ' > ' + gzip_filename)
    if !status.success?
      raise stderr
    end

    gzip_filename
  end

  def gunzip_files(filenames)
    unzipped_filepaths = []
    filenames.each do |filename|
      sanitized_filename = sanitize_filename(filename)
      gunzipped_filename = sanitized_filename.gsub(/\.gz/i, '')
      File.delete(gunzipped_filename) if File.exist?(gunzipped_filename)
      puts "Gunzipping #{sanitized_filename}"
      stdout, stderr, status = Open3.capture3('gunzip', sanitized_filename)
      if !status.success?
        raise stderr
      end
      unzipped_filepaths << gunzipped_filename
    end
    unzipped_filepaths
  end

  def sanitize_filename(filename)
    regex = /\?|\%|\*|\"|\<|\>|\s+/i
    sanitized_filename = filename.gsub(regex, '_')
    sanitized_filename
  end

end
