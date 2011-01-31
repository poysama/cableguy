module Palmade::Cableguy
  module Builders
    def self.load_all_builders
      CableTemplate
      CableMkdir
      CableChmod
      CableSymlink
      CableCustom
      CableMove
    end

    autoload :CableChmod, File.join(File.dirname(__FILE__), 'builders/cable_chmod')
    autoload :CableCustom, File.join(File.dirname(__FILE__), 'builders/cable_custom')
    autoload :CableMkdir, File.join(File.dirname(__FILE__), 'builders/cable_mkdir')
    autoload :CableSymlink, File.join(File.dirname(__FILE__), 'builders/cable_symlink')
    autoload :CableTemplate, File.join(File.dirname(__FILE__), 'builders/cable_template')
    autoload :CableMove, File.join(File.dirname(__FILE__), 'builders/cable_move')
  end
end

