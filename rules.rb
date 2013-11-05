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
  # NOTE: Currently depends on features to be released in Maid v0.4.0

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
    # I changed the default OS X screenshot directory from `~/Desktop` to `~/Outbox`
    dir(['~/Outbox/*.{eml,mp3,pdf}', '~/Outbox/Screen shot *']).each do |p|
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
    {
      'js'  => 'javascript',
      'rb'  => 'ruby',
      'sql' => 'sql',
      'js'  => 'javascript',
      'rb'  => 'ruby',
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
    trash dir('~/Downloads/ATT*.c')

    # It's rare that I download these file types and don't put them somewhere else quickly.  More often, these are still in Downloads because it was an accident.
    dir('~/Downloads/*.{csv,doc,docx,gem,vcs,ics,ppt,js,rb,xml,xlsx}').each do |p|
      trash(p) if 3.days.since?(accessed_at(p))
    end

    trash verbose_dupes_in('~/Downloads/*')
  end

  rule 'Trash downloads that have a limited lifetime' do
    # Often shared from Skype, etc
    dir('~/Downloads/Screenshot *').each do |p|
      trash(p) if 3.days.since?(accessed_at(p))
    end
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

  rule 'Trash downloaded software' do
    # These can generally be downloaded again very easily if needed... but just in case, give me a few days before trashing them.
    dir('~/Downloads/*.{deb,dmg,exe,pkg,rpm}').each do |p|
      trash(p) if 3.days.since?(accessed_at(p))
    end

    osx_app_extensions = %w(app dmg pkg wdgt)
    osx_app_patterns = osx_app_extensions.map { |ext| (/\.#{ext}\/$/) }
    
    zips_with_osx_apps_inside = dir('~/Downloads/*.zip').select do |path|
      candidates = zipfile_contents(path)
      candidates.any? { |c| osx_app_patterns.any? { |re| c.match(re) } }
    end
    
    trash(zips_with_osx_apps_inside)
  end

  rule 'Collect downloaded videos to watch later' do
    # This isn't quite right on OSX (would be "Movies" instead of "Videos"), but I've tended to prefer this.
    move where_content_type(dir('~/Downloads/*'), 'video'), mkdir('~/Videos/To Watch')
  end

  rule 'Assume audio is music and add it to my player' do
    move where_content_type(dir('~/Downloads/*'), 'audio'), mkdir('~/Music/iTunes/iTunes Media/Automatically Add to iTunes/')
  end

  rule 'Keep menus around' do
    move(dir('~/Downloads/*menu*.pdf'), mkdir('~/Reference/Menus/'))
  end

  rule 'Put sales fliers on my phone via Dropbox' do
    # Intentionally overwrites
    move(dir('~/Downloads/wrd.pdf'), mkdir('~/Dropbox/Pending/'))
  end

  rule 'Put things to read in my library' do
    move(dir('~/Downloads/*.{epub,mobi,pdf}'), mkdir('~/Books/To Read/'))
  end

  # Cleaning up after Maid
  # ----------------------

  # This one should be after all the other 'Downloads' and 'Outbox' rules
  rule 'Remove empty directories' do
    dir(['~/Downloads/*', '~/Outbox/*']).each do |path|
      if File.directory?(path) && dir("#{ path }/*").empty?
        trash(path)
      end
    end
  end

  # TODO: move from ~/Public/Drop Box/ somewhere
end
