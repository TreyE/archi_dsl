module ArchiDsl
  module Dsl
    module Business
      class Representation < ModelElement
        def base_folder
          Organizations::BUSINESS_BASE
        end

        def xsi_type
          "Representation"
        end
      end
    end
  end
end