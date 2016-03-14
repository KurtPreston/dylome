# Load paperclip config
paperclip_config = YAML.load(ERB.new(File.new("#{Rails.root}/config/paperclip.yml").read).result)
if paperclip_config[Rails.env]
  Paperclip::Attachment.default_options.merge!(paperclip_config[Rails.env])
end
