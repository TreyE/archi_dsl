module ArchiDsl
  module Dsl
    module Application
      class ApplicationComponent < ModelElement
        def base_folder
          Organizations::APPLICATION_BASE
        end

        def xsi_type
          "ApplicationComponent"
        end
      end
    end
  end
end
