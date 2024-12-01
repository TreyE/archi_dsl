module ArchiDsl
  module Dsl
    module Business
      class BusinessCollaboration < ModelElement
        def base_folder
          Organizations::BUSINESS_BASE
        end

        def xsi_type
          "BusinessCollaboration"
        end
      end
    end
  end
end
