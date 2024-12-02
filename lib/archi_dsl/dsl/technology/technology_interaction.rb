module ArchiDsl
  module Dsl
    module Technology
      class TechnologyInteraction < ModelElement
        def base_folder
          Organizations::TECHNOLOGY_BASE
        end

        def xsi_type
          "TechnologyInteraction"
        end
      end
    end
  end
end