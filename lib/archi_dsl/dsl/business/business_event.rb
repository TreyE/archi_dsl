module ArchiDsl
  module Dsl
    module Business
      class BusinessEvent < ModelElement
        def base_folder
          Organizations::BUSINESS_BASE
        end

        def xsi_type
          "BusinessEvent"
        end
      end
    end
  end
end
