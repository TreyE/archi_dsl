module ArchiDsl
  module Dsl
    module Physical
      class DistributionNetwork < ModelElement
        def base_folder
          Organizations::TECHNOLOGY_BASE
        end

        def xsi_type
          "DistributionNetwork"
        end
      end
    end
  end
end