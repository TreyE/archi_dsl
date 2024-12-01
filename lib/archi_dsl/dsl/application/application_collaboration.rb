module ArchiDsl
  module Dsl
    module Application
      class ApplicationCollaboration < ModelElement
        def base_folder
          Organizations::APPLICATION_BASE
        end

        def xsi_type
          "ApplicationCollaboration"
        end
      end
    end
  end
end
