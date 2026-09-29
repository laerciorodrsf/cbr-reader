# frozen_string_literal: true

require 'tmpdir'

class Archive
  def initialize(path)
    @path = path
  end

  def extract
    directory = Dir.mktmpdir('cbr-reader')

    success = system(
      'unzip',
      '-q',
      @path,
      '-d',
      directory
    )

    abort 'It is not possible to open the CBR file.' unless success

    directory
  end
end
