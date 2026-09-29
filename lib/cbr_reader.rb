# frozen_string_literal: true

require_relative 'archive'
require_relative 'terminal'

require 'tty-reader'

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

    control_page(pages)
  end

  private

  def display_page(page)
    rows, columns = Terminal.size

    system('kitten', 'icat', '--place', "#{columns}x#{rows}@0x0", page)
  end

  def control_page(pages)
    current_page_idx = 0
    last_page = pages.length - 1

    reader = TTY::Reader.new

    loop do
      system('clear')
      display_page(pages[current_page_idx])

      key = reader.read_keypress

      case key
      when 'q'
        break
      when "\e[C"
        current_page_idx += 1 if current_page_idx < last_page
      when "\e[D"
        current_page_idx -= 1 if current_page_idx.positive?
      end
    end
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
