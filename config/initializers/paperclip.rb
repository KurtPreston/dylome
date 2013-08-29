# Load paperclip config
paperclip_config = YAML.load_file("#{Rails.root}/config/paperclip.yml")
if paperclip_config[Rails.env]
  Paperclip::Attachment.default_options.merge!(paperclip_config[Rails.env])
end
