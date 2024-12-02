module ArchiDsl
  module Dsl
    module Implementation
      class Gap < ModelElement
        def base_folder
          Organizations::IMPLEMENTATION_BASE
        end

        def xsi_type
          "Gap"
        end
      end
    end
  end
end