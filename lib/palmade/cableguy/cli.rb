require 'thor'

module Palmade::Cableguy
  class Cli < Thor
    desc "build", "begin cabling the app's config files"

    def build
      Palmade::Cableguy::Dsl.evaluate(File.read('Cablefile'))
    end

    default_task :build
  end
end
