module ArchiDsl
  module Dsl
    module Application
      class ApplicationFunction < ModelElement
        def base_folder
          Organizations::APPLICATION_BASE
        end

        def xsi_type
          "ApplicationFunction"
        end
      end
    end
  end
end