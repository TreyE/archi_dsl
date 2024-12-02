module ArchiDsl
  module Dsl
    module Technology
      class TechnologyCollaboration < ModelElement
        def base_folder
          Organizations::TECHNOLOGY_BASE
        end

        def xsi_type
          "TechnologyCollaboration"
        end
      end
    end
  end
end