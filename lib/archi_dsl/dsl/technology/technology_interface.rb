module ArchiDsl
  module Dsl
    module Technology
      class TechnologyInterface < ModelElement
        def base_folder
          Organizations::TECHNOLOGY_BASE
        end

        def xsi_type
          "TechnologyInterface"
        end
      end
    end
  end
end