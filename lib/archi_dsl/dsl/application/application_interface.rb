module ArchiDsl
  module Dsl
    module Application
      class ApplicationInterface < ModelElement
        def base_folder
          Organizations::APPLICATION_BASE
        end

        def xsi_type
          "ApplicationInterface"
        end
      end
    end
  end
end