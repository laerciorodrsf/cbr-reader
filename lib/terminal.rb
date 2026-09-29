# frozen_string_literal: true

class Terminal
  def self.size
    IO.console.winsize
  end

  def self.width
    size[1]
  end

  def self.height
    size[0]
  end
end
