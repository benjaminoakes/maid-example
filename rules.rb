# My personal Maid rules.
#
# I run them once an hour using `cron`.
#
# As a rule of thumb, keep in mind that it's easier to bend your process to Maid rather than bending Maid to your process.  That means making new folders, marking files with metadata (even just extensions), etc. just so you can have them automatically cleaned up.
Maid.rules do
  # NOTE: Some of these rules depend on features in Maid 0.1.3 (still in beta as of 2012.10.20).

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
    ].flatten.each do |p|
      trash(p) if 1.week.since?(accessed_at(p))
    end

    dir('~/Outbox/*.log').each do |p|
      trash(p) if 1.week.since?(created_at(p))
    end
  end

  # Downloads
  # ---------

  rule "Trash files that shouldn't have been downloaded" do
    trash(dir('~/Downloads/ATT*.c'))
    trash(dir('~/Downloads/* (1).*'))
    trash(dir('~/Downloads/* (2).*'))
    trash(dir('~/Downloads/*.1'))
  end

  rule 'Collect downloaded videos to watch later' do
    # This isn't quite right on OSX (would be "Movies"), but I've tended to prefer this.
    to_watch = '~/Videos/To Watch'
    mkdir(to_watch)

    # I'm hoping to simplify this with mimetypes.  See the [Add filetype detection](https://github.com/benjaminoakes/maid/issues/51) issue.
    %w(mov mp4 m4v ogv webm).each do |ext|
      move(dir("~/Downloads/*.#{ ext }"), to_watch)
    end
  end
end
