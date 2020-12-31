# frozen_string_literal: true

Encoding.default_external = 'UTF-8'

require "crude_renamer/version"

module CrudeRenamer
  class LinesNotFoundError < IOError; end

  def self.root
    Pathname.new(File.absolute_path(File.join(File.dirname(__FILE__), '..')))
  end

  autoload :FileFinder , 'crude_renamer/file_finder'
  autoload :Renamer , 'crude_renamer/renamer'
  autoload :Shell , 'crude_renamer/shell'
end
