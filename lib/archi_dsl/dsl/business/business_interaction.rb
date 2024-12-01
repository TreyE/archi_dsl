module ArchiDsl
  module Dsl
    module Business
      class BusinessInteraction < ModelElement
        def base_folder
          Organizations::BUSINESS_BASE
        end

        def xsi_type
          "BusinessInteraction"
        end
      end
    end
  end
end