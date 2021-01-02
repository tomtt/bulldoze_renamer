# frozen_string_literal: true

Encoding.default_external = 'UTF-8'

require "crude_renamer/version"

module CrudeRenamer
  class LinesNotFoundError < IOError; end

  def self.root
    Pathname.new(File.absolute_path(File.join(File.dirname(__FILE__), '..')))
  end

  autoload :FileContentSubstitutor , 'crude_renamer/file_content_substitutor'
  autoload :FileFinder , 'crude_renamer/file_finder'
  autoload :RenamingOrchestrator , 'crude_renamer/renaming_orchestrator'
  autoload :Shell , 'crude_renamer/shell'
  autoload :StringInflector , 'crude_renamer/string_inflector'
end
