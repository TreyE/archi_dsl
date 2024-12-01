module ArchiDsl
  module Dsl
    module Business
      class Product < ModelElement
        def base_folder
          Organizations::BUSINESS_BASE
        end

        def xsi_type
          "Product"
        end
      end
    end
  end
end