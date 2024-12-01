module ArchiDsl
  module Dsl
    module Application
      class ApplicationProcess < ModelElement
        def base_folder
          Organizations::APPLICATION_BASE
        end

        def xsi_type
          "ApplicationProcess"
        end
      end
    end
  end
end