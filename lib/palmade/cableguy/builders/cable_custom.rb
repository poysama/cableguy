module Palmade::Cableguy
  class Builders::CableCustom < Cable
    add_as :custom

    def configure(cabler, cabling, target)
      unless @block.nil?
        @block.call(self)
      end
    end
  end
end

