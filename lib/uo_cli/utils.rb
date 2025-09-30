def format_float(num)
  s = "#{num.round(2)}"
  float_as_string = s.gsub(/(\d)(?=(\d{3})+\.)/, '\1,') # add commas as thousands separators
end
