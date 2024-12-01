module ArchiDsl
  module Dsl
    module Business
      class BusinessService < ModelElement
        def base_folder
          Organizations::BUSINESS_BASE
        end

        def xsi_type
          "BusinessService"
        end
      end
    end
  end
end