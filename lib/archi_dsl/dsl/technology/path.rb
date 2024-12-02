module ArchiDsl
  module Dsl
    module Technology
      class Path < ModelElement
        def base_folder
          Organizations::TECHNOLOGY_BASE
        end

        def xsi_type
          "Path"
        end
      end
    end
  end
end