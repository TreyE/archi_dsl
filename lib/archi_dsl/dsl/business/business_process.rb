module ArchiDsl
  module Dsl
    module Business
      class BusinessProcess < ModelElement
        def base_folder
          Organizations::BUSINESS_BASE
        end

        def xsi_type
          "BusinessProcess"
        end
      end
    end
  end
end
