module ArchiDsl
  module Dsl
    module Business
      class Contract < ModelElement
        def base_folder
          Organizations::BUSINESS_BASE
        end

        def xsi_type
          "Contract"
        end
      end
    end
  end
end