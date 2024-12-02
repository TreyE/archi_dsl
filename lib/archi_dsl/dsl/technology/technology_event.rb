module ArchiDsl
  module Dsl
    module Technology
      class TechnologyEvent < ModelElement
        def base_folder
          Organizations::TECHNOLOGY_BASE
        end

        def xsi_type
          "TechnologyEvent"
        end
      end
    end
  end
end