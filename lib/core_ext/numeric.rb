class Numeric
  def duration(include_hour = true)
    time = Time.at(self).utc

    if self.floor == self
      if self > 1.hour || include_hour
        time.strftime("%H:%M:%S")
      elsif self > 1.minute
        time.strftime("%M:%S")
      else
        time.strftime("%S")
      end
    else
      if self > 1.hour || include_hour
        time.strftime("%H:%M:%S.%L")
      elsif self > 1.minute
        time.strftime("%M:%S.%L")
      else
        time.strftime("%S.%L")
      end
    end
  end
end
