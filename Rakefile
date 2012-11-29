task :default do
  sh('docco -o . *.rb')
  FileUtils.cp('rules.html', 'index.html', :verbose => true)
end
