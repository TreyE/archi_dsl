module ArchiDsl
  module Dsl
    module Implementation
      class WorkPackage < ModelElement
        def base_folder
          Organizations::IMPLEMENTATION_BASE
        end

        def xsi_type
          "WorkPackage"
        end
      end
    end
  end
end