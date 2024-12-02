module ArchiDsl
  module Dsl
    module Implementation
      class Deliverable < ModelElement
        def base_folder
          Organizations::IMPLEMENTATION_BASE
        end

        def xsi_type
          "Deliverable"
        end
      end
    end
  end
end