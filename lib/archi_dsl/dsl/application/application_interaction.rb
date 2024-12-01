module ArchiDsl
  module Dsl
    module Application
      class ApplicationInteraction < ModelElement
        def base_folder
          Organizations::APPLICATION_BASE
        end

        def xsi_type
          "ApplicationInteraction"
        end
      end
    end
  end
end