module ArchiDsl
  module Dsl
    module Physical
      class Material < ModelElement
        def base_folder
          Organizations::TECHNOLOGY_BASE
        end

        def xsi_type
          "Material"
        end
      end
    end
  end
end