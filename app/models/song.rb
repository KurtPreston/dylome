class Song < ActiveRecord::Base
  has_attached_file :uploaded_file
  validates_attachment :uploaded_file,  presence: true

  has_attached_file :processed_file

  validates_presence_of :name

  after_create :proccess_upload

  def filename_without_extension
    if uploaded_file_file_name.present?
      uploaded_file_file_name.split('.')[0..-2].join
    end
  end

  def formatted_duration
    if length >= 3600
      Time.at(length).utc.strftime("%H:%M:%S")
    else
      Time.at(length).utc.strftime("%M:%S")
    end
  end

  def process_upload
    input_file = uploaded_file.path
    #output_file = "#{tmp_dir}/#{filename_without_extension}-dylom.mp3"

    # Retrieve file
    # download_command = IO.popen ['wget', '-P', tmp_dir, uploaded_file.url]
    # download_command.read
    # download_command.close

    # Get song length
    song_length_command = IO.popen ["ffmpeg", "-i", input_file, :err=>[:child, :out]] #we care about standard error
    result = song_length_command.read
    song_length_command.close

    # Update song length
    puts result
    duration_string = result.match("Duration: ([0-9]+):([0-9]+):([0-9]+).([0-9]+)")
    hours = duration_string[1].to_i
    minutes = duration_string[2].to_i
    seconds = duration_string[3].to_i
    update_attribute(:length, hours * 3600 + minutes * 60 + seconds)
  ensure
    #FileUtils.rm input_file if File.exists?(input_file)
  end
end
