module ArchiDsl
  module Dsl
    module Application
      class ApplicationEvent < ModelElement
        def base_folder
          Organizations::APPLICATION_BASE
        end

        def xsi_type
          "ApplicationEvent"
        end
      end
    end
  end
end