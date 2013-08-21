json.array!(@songs) do |song|
  json.extract! song, :name, :length, :bpm
  json.url song_url(song, format: :json)
end
