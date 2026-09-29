# frozen_string_literal: true

require_relative 'archive'

class CbrReader
  SUPPORTED_EXTENSIONS = %w[.cbr .cbz].freeze
  IMAGE_EXTENSIONS = %w[.jpg .jpeg .png .webp].freeze

  def initialize(path)
    @path = File.expand_path(path)
  end

  def run
    validate_file!

    directory = Archive.new(@path).extract
    pages = find_pages(directory)

    abort 'No images found' unless pages

    pages.each { |page| display_page(page) }
  end

  private

  def display_page(page)
    system('kitten', 'icat', page)
  end

  def validate_file!
    abort "File not found: #{@path}" unless File.file?(@path)

    extension = File.extname(@path).downcase

    abort 'File not supported.' unless SUPPORTED_EXTENSIONS.include?(extension)
  end

  def find_pages(directory)
    Dir.glob(File.join(directory, '**', '*'))
       .select { |path| IMAGE_EXTENSIONS.include?(File.extname(path).downcase) }
       .sort
  end
end
