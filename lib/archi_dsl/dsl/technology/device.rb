module ArchiDsl
  module Dsl
    module Technology
      class Device < ModelElement
        def base_folder
          Organizations::TECHNOLOGY_BASE
        end

        def xsi_type
          "Device"
        end
      end
    end
  end
end