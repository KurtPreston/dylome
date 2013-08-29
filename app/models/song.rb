class Song < ActiveRecord::Base
  has_attached_file :uploaded_file
  validates_attachment :uploaded_file, presence: true, size: {in: 0..20.megabytes}

  has_attached_file :processed_file

  validates_presence_of :name, :bpm
  validates_numericality_of :bpm, greater_than_or_equal_to: 50, less_than_or_equal_to: 200

  after_create :calculate_song_length
  after_create :dylomify

  def filename_without_extension
    if uploaded_file_file_name.present?
      uploaded_file_file_name.split('.')[0..-2].join
    end
  end

  def formatted_duration
    length.duration(false)
  end

  def uploaded_file_copy
    unless @uploaded_file_copy && File.exists?(@uploaded_file_copy)
      original_file = if uploaded_file.queued_for_write.any?
                        uploaded_file.queued_for_write[:original].path
                      else
                        uploaded_file.path
                      end

      @uploaded_file_copy = tmp_dir.join("#{id}.mp3").to_s
      FileUtils.rm @uploaded_file_copy if File.exists?(@uploaded_file_copy)
      FileUtils.copy(original_file, @uploaded_file_copy)

      @uploaded_file_copy
    end

    raise "File not copied" if (@uploaded_file_copy.nil? || !File.exists?(@uploaded_file_copy))
    @uploaded_file_copy
  end

  def calculate_song_length
    begin
      input_file = uploaded_file_copy

      # Get song length
      song_length_command = IO.popen ["ffmpeg", "-i", input_file, :err=>[:child, :out]] #we care about standard error
      result = song_length_command.read
      song_length_command.close

      # Update song length
      duration_string = result.match("Duration: ([0-9]+):([0-9]+):([0-9]+).([0-9]+)")
      hours = duration_string[1].to_i
      minutes = duration_string[2].to_i
      seconds = duration_string[3].to_i
      update_attribute(:length, hours * 3600 + minutes * 60 + seconds)
    ensure
      FileUtils.rm input_file if input_file && File.exists?(input_file)
    end
  end

  def dylomify(offset = 0)
    output_files = []
    begin
      (offset.to_f..length).step(chunk_duration).each_with_index do |start_time, chunk_num|
        end_time = start_time + chunk_duration

        output_file = tmp_dir.join("#{id}-#{chunk_num}.mp3")
        output_files << output_file

        # Create chunk
        chunk_command = %W(ffmpeg -i #{uploaded_file_copy} -vcodec copy -acodec copy -ss #{start_time.duration} -t #{chunk_duration.duration} #{output_file})
        chunk_command = IO.popen chunk_command
        chunk_command.read
        chunk_command.close
      end

      # Write the file list
      file_list = tmp_dir.join("#{id}-filelist.txt")
      file_list_contents = output_files.reverse.map {|f| "file '#{f}'"}.join("\n")
      File.open(file_list, 'w') { |file| file.write(file_list_contents) }
      output_files << file_list

      # Combine chunks
      dylomified_file = tmp_dir.join("#{uploaded_file_file_name}-dylome.mp3")
      concat_command = %W(ffmpeg -f concat -i #{file_list} -c copy #{dylomified_file})
      concat_command = IO.popen concat_command
      concat_command.read
      concat_command.close
      output_files << dylomified_file

      # Upload processed file
      update_attribute(:processed_file, File.new(dylomified_file))
    ensure
      FileUtils.rm output_files
    end
  end

  def chunk_duration(num_beats = 4)
    60.to_f / bpm * num_beats
  end

  def tmp_dir
    tmp_dir = Rails.root.join('tmp', 'dylome')
    Dir::mkdir(tmp_dir) unless File.exists?(tmp_dir)
    tmp_dir
  end
end
