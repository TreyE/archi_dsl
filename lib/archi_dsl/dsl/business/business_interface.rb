module ArchiDsl
  module Dsl
    module Business
      class BusinessInterface < ModelElement
        def base_folder
          Organizations::BUSINESS_BASE
        end

        def xsi_type
          "BusinessInterface"
        end
      end
    end
  end
end
