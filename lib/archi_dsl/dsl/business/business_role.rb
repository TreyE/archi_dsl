module ArchiDsl
  module Dsl
    module Business
      class BusinessRole < ModelElement
        def base_folder
          Organizations::BUSINESS_BASE
        end

        def xsi_type
          "BusinessRole"
        end
      end
    end
  end
end
