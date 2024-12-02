module ArchiDsl
  module Dsl
    module Technology
      class Artifact < ModelElement
        def base_folder
          Organizations::TECHNOLOGY_BASE
        end

        def xsi_type
          "Artifact"
        end
      end
    end
  end
end