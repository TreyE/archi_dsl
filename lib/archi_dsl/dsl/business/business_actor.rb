module ArchiDsl
  module Dsl
    module Business
      class BusinessActor < ModelElement
        def base_folder
          Organizations::BUSINESS_BASE
        end

        def xsi_type
          "BusinessActor"
        end
      end
    end
  end
end
