module ArchiDsl
  module Dsl
    module Technology
      class TechnologyFunction < ModelElement
        def base_folder
          Organizations::TECHNOLOGY_BASE
        end

        def xsi_type
          "TechnologyFunction"
        end
      end
    end
  end
end