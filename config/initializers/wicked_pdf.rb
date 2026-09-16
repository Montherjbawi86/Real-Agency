WickedPdf.configure do |config|
  candidates = [
    "/opt/homebrew/bin/wkhtmltopdf",
    "/usr/local/bin/wkhtmltopdf"
  ]
  exe = candidates.find { |p| File.exist?(p) }
  config.exe_path = exe if exe
  config.enable_local_file_access = true
end
