# My personal Maid rules.
#
# I run them once an hour using `cron`.
#
# As a rule of thumb, keep in mind that it's easier to bend your process to Maid rather than bending Maid to your process.  That means making new folders, marking files with metadata (even just extensions), etc. just so you can have them automatically cleaned up.
Maid.rules do
  # NOTE: Some of these rules depend on features in Maid 0.1.3 (still in beta as of 2012.10.20).

  rule 'Dump my temporary folder' do
    mkdir('~/tmp')
    trash('~/tmp')
    mkdir('~/tmp')
  end
end
