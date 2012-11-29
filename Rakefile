task :default do
  sh('git merge master')
  sh('docco -o . *.rb')
  FileUtils.cp('rules.html', 'index.html', :verbose => true)
end
