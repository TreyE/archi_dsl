module ArchiDsl
  module Dsl
    module Application
      class ApplicationService < ModelElement
        def base_folder
          Organizations::APPLICATION_BASE
        end

        def xsi_type
          "ApplicationService"
        end
      end
    end
  end
end