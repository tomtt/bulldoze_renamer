# frozen_string_literal: true

Encoding.default_external = 'UTF-8'

require "bulldoze_renamer/version"

module BulldozeRenamer
  class LinesNotFoundError < IOError; end

  def self.root
    Pathname.new(File.absolute_path(File.join(File.dirname(__FILE__), '..')))
  end

  autoload :FileContentSubstitutor , 'bulldoze_renamer/file_content_substitutor'
  autoload :FileFinder , 'bulldoze_renamer/file_finder'
  autoload :RenamingOrchestrator , 'bulldoze_renamer/renaming_orchestrator'
  autoload :Shell , 'bulldoze_renamer/shell'
  autoload :StringInflector , 'bulldoze_renamer/string_inflector'
end
