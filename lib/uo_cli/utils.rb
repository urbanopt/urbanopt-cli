def format_float(num)
  s = '%.2f' % num
  float_as_string = s.gsub(/(\d)(?=(\d{3})+\.)/, '\1,')
  # float_as_string.to_f
end
