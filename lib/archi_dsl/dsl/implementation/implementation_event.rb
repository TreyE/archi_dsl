module ArchiDsl
  module Dsl
    module Implementation
      class ImplementationEvent < ModelElement
        def base_folder
          Organizations::IMPLEMENTATION_BASE
        end

        def xsi_type
          "ImplementationEvent"
        end
      end
    end
  end
end