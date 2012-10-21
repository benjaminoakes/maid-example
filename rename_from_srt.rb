Maid.rules do
  # If the current directory is full of episodes and subtitles like this:
  #
  #     1x01.m4v
  #     1x01 - Pilot.srt
  #     1x02.m4v
  #     1x02 - Next Episode.srt
  #     ...
  #
  # This rule will rename it like this:
  #
  #     1x01 - Pilot.m4v
  #     1x01 - Pilot.srt
  #     1x02 - Next Episode.m4v
  #     1x02 - Next Episode.srt
  #     ...
  #
  rule 'Add titles to episodes' do
    dir('*.srt').sort.each do |srt|
      dirname = File.dirname(srt)
      base = File.basename(srt, '.srt')
      old = "#{ base.split(' - ').first }.m4v"
      new = "#{ base }.m4v"

      if File.exist?(old)
        move(old, new)
      end
    end
  end
end
