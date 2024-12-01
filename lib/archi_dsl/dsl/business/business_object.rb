module ArchiDsl
  module Dsl
    module Business
      class BusinessObject < ModelElement
        def base_folder
          Organizations::BUSINESS_BASE
        end

        def xsi_type
          "BusinessObject"
        end
      end
    end
  end
end