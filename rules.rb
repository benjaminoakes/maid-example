# These are the [Maid](https://github.com/benjaminoakes/maid) rules that I
# ([@benjaminoakes](https://github.com/benjaminoakes)) use.  I run them once an hour using `cron`.
#
# You can find more information [on GitHub](https://github.com/benjaminoakes/maid-example).
#
# As a rule of thumb, keep in mind that it's easier to bend your process to Maid
# rather than bending Maid to your process.  That means making new folders, 
# marking files with metadata (even just extensions), etc. just so you can have
# them automatically cleaned up.
Maid.rules do
  # Cleaning Temporary Files
  # ------------------------

  rule 'Dump my temporary folder' do
    mkdir('~/tmp')
    trash('~/tmp')
    mkdir('~/tmp')
  end

  rule 'Trash old temporary files' do
    dir('~/Outbox/*.tmp.*').each do |p|
      trash(p) if 1.week.since?(modified_at(p))
    end
  end

  rule 'Trash working files not worth keeping' do
    [
      dir('~/Outbox/*.eml'),
      dir('~/Outbox/*.mp3'),
      dir('~/Outbox/*.pdf'),
      # I changed the default OS X screenshot directory from `~/Desktop` to `~/Outbox`
      dir('~/Outbox/Screen shot *'),
    ].flatten.each do |p|
      trash(p) if 1.week.since?(modified_at(p))
    end

    dir('~/Outbox/*.log').each do |p|
      trash(p) if 1.week.since?(created_at(p))
    end
  end

  rule 'Trash accidentally saved files' do
    # I'm targeting places I'm likely to have used `vi`.

    trash('~/:w')
    trash('~/Outbox/:w')

    trash(dir('~/Code/**/:w'))
    trash(dir('~/Projects/**/:w'))
  end

  # I write little test programs sometimes, and I keep them around for reference.
  rule 'Archive code snippets' do
    base_archive_path = '~/Code/snippets/'

    {
      'html' => 'html',
      'js' => 'javascript',
      'rb' => 'ruby',
      'sql' => 'sql',
    }.each do |ext, directory|
      specific_archive_path = "~/Code/snippets/#{ directory }"

      dir("~/Outbox/*.#{ ext }").each do |path|
        if 1.week.ago > accessed_at(path)
          mkdir(specific_archive_path)
          move(path, specific_archive_path)
        end
      end
    end
  end

  # Cleaning Downloads
  # ------------------

  rule "Trash files that shouldn't have been downloaded" do
    # Annoying extra text files from Exchange attachments
    trash(dir('~/Downloads/ATT*.c'))

    # It's rare that I download these file types and don't put them somewhere else quickly.  More often, these are still in Downloads because it was an accident.
    [
      dir('~/Downloads/*.csv'),
      dir('~/Downloads/*.doc'),
      dir('~/Downloads/*.docx'),
      dir('~/Downloads/*.ics'),
      dir('~/Downloads/*.ppt'),
      dir('~/Downloads/*.js'),
      dir('~/Downloads/*.rb'),
      dir('~/Downloads/*.xml'),
      dir('~/Downloads/*.xlsx'),
    ].flatten.each do |p|
      trash(p) if 3.days.since?(accessed_at(p))
    end

    # Quick 'n' dirty duplicate download detection
    trash(dir('~/Downloads/* (1).*'))
    trash(dir('~/Downloads/* (2).*'))
    trash(dir('~/Downloads/*.1'))

    trash(dir('~/Downloads/Chart_of_the_Day.png'))
    trash(dir('~/Downloads/Chart_of_the_Day*.png'))
    trash(dir('~/Downloads/conf_recorded_on_*.mp3'))
    trash(dir('~/Downloads/conf_recorded_on_*.ogg'))
  end

  rule 'Trash files downloaded while developing' do
    if Maid::Platform.osx?
      dir('~/Downloads/*').each do |path|
        if downloaded_from(path).any? { |url| url.match(/^http:\/\/localhost/) }
          trash(path)
        end
      end
    end
  end

  rule 'Collect downloaded videos to watch later' do
    # This isn't quite right on OSX (would be "Movies"), but I've tended to prefer this.
    to_watch = '~/Videos/To Watch'
    mkdir(to_watch)

    # I'm hoping to simplify this with mimetypes.  See the [Add filetype
    # detection](https://github.com/benjaminoakes/maid/issues/51) issue.
    %w(mov mp4 m4v ogv webm).each do |ext|
      move(dir("~/Downloads/*.#{ ext }"), to_watch)
    end
  end

  rule 'Keep menus around' do
    path = '~/Reference/Menus/'
    mkdir(path)
    move(dir('~/Downloads/*menu*.pdf'), path)
  end

  rule 'Put sales fliers on my phone via Dropbox' do
    pending = '~/Dropbox/Pending/'
    mkdir(pending)
    # Intentionally overwrites
    move(dir('~/Downloads/wrd.pdf'), pending)
  end

  rule 'Put things to read in my library' do
    book_library = '~/Books/To Read/'

    mkdir(book_library)

    move(dir('~/Downloads/*.epub'), book_library)
    move(dir('~/Downloads/*.mobi'), book_library)
    move(dir('~/Downloads/*.pdf'), book_library)
  end

  rule 'Trash downloaded software' do
    # These can generally be downloaded again very easily if needed... but just in case, give me a few days before trashing them.
    [
      dir('~/Downloads/*.deb'),
      dir('~/Downloads/*.dmg'),
      dir('~/Downloads/*.exe'),
      dir('~/Downloads/*.pkg'),
    ].flatten.each do |p|
      trash(p) if 3.days.since?(accessed_at(p))
    end

    # FIXME: `zipfile_contents` is complaining about zip formats on Ubuntu.
    #
    #     osx_app_extensions = %w(app dmg pkg wdgt)
    #     osx_app_patterns = osx_app_extensions.map { |ext| (/\.#{ext}\/$/) }
    #     
    #     zips_with_osx_apps_inside = dir('~/Downloads/*.zip').select do |path|
    #       candidates = zipfile_contents(path)
    #       candidates.any? { |c| osx_app_patterns.any? { |re| c.match(re) } }
    #     end
    #     
    #     trash(zips_with_osx_apps_inside)
  end

  # Cleaning up after Maid
  # ----------------------

  # This one should be after all the other 'Downloads' and 'Outbox' rules
  rule 'Remove empty directories' do
    (dir('~/Downloads/*') + dir('~/Outbox/*')).each do |path|
      if File.directory?(path) && Dir["#{path}/*"].empty?
        trash(path)
      end
    end
  end
end
