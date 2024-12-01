module ArchiDsl
  module Dsl
    module Business
      class BusinessFunction < ModelElement
        def base_folder
          Organizations::BUSINESS_BASE
        end

        def xsi_type
          "BusinessFunction"
        end
      end
    end
  end
end
