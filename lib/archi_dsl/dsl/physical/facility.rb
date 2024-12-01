module ArchiDsl
  module Dsl
    module Physical
      class Facility < ModelElement
        def base_folder
          Organizations::TECHNOLOGY_BASE
        end

        def xsi_type
          "Facility"
        end
      end
    end
  end
end