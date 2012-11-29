# Personal Maid rules for [@benjaminoakes](https://github.com/benjaminoakes).
#
# I run them once an hour using `cron`.
#
# As a rule of thumb, keep in mind that it's easier to bend your process to Maid
# rather than bending Maid to your process.  That means making new folders, 
# marking files with metadata (even just extensions), etc. just so you can have
# them automatically cleaned up.
Maid.rules do
  # Temporary Files
  # ---------------

  rule 'Dump my temporary folder' do
    mkdir('~/tmp')
    trash('~/tmp')
    mkdir('~/tmp')
  end

  rule 'Trash old temporary files' do
    dir('~/Outbox/*.tmp.*').each do |p|
      trash(p) if 1.week.since?(accessed_at(p))
    end
  end

  rule 'Trash working files not worth keeping' do
    [
      dir('~/Outbox/*.eml'),
      dir('~/Outbox/*.mp3'),
      # I changed the default OS X screenshot directory from '~/Desktop' to '~/Outbox'
      dir('~/Outbox/Screen shot *'),
    ].flatten.each do |p|
      trash(p) if 1.week.since?(accessed_at(p))
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

  # Downloads
  # ---------

  rule "Trash files that shouldn't have been downloaded" do
    # Annoying extra text files from Exchange attachments
    trash(dir('~/Downloads/ATT*.c'))

    # Quick 'n' dirty duplicate download detection
    trash(dir('~/Downloads/* (1).*'))
    trash(dir('~/Downloads/* (2).*'))
    trash(dir('~/Downloads/*.1'))
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

  rule 'Keep menus around' do
    path = '~/Reference/Menus/'
    mkdir(path)
    move(dir('~/Downloads/*menu*.pdf'), path)
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

  rule 'Put books in my library' do
    book_library = '~/Books/'

    move(dir('~/Downloads/*.mobi'), book_library)
    move(dir('~/Downloads/*.epub'), book_library)

    if Maid::Platform.osx?
      dir('~/Downloads/*.pdf').each do |path|
        if downloaded_from(path).any? { |url| url.match(/book/) }
          move(path, book_library)
        end
      end
    end
  end

  rule 'Trash downloaded software' do
    trash(dir('~/Downloads/*.deb'))
    trash(dir('~/Downloads/*.dmg'))
    trash(dir('~/Downloads/*.exe'))

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

  # Maid cleanup
  # ------------

  # This one should be after all the other 'Downloads' and 'Outbox' rules
  rule 'Remove empty directories' do
    (dir('~/Downloads/*') + dir('~/Outbox/*')).each do |path|
      if File.directory?(path) && Dir["#{path}/*"].empty?
        trash(path)
      end
    end
  end
end
