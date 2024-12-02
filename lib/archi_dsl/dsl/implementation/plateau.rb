module ArchiDsl
  module Dsl
    module Implementation
      class Plateau < ModelElement
        def base_folder
          Organizations::IMPLEMENTATION_BASE
        end

        def xsi_type
          "Plateau"
        end
      end
    end
  end
end