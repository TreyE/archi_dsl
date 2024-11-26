module ArchiDsl
  module Dsl
    module ElementMethods
      def self.define_real_element_method(name, ele_kind)
        class_eval(<<-RUBY_CODE)
          def #{name}(element_name, element_id = "e-" + SecureRandom.uuid, &blk)
            ele = RealElement.new(@association_registry, "#{ele_kind}", element_name, element_id, &blk)
            @element_lookup.add_element(ele)
            @children << ele
            ele
          end
        RUBY_CODE
      end

      REAL_ELEMENT_SET = [
        [:business_actor, "BusinessActor"],
        [:business_role, "BusinessRole"],
        [:business_collaboration, "BusinessCollaboration"],
        [:business_interface, "BusinessInterface"],
        [:business_process, "BusinessProcess"],
        [:business_function, "BusinessFunction"],
        [:business_interaction, "BusinessInteraction"],
        [:business_event, "BusinessEvent"],
        [:business_service, "BusinessService"],
        [:business_object, "BusinessObject"],
        [:contract, "Contract"],
        [:representation, "Representation"],
        [:product, "Product"],
        [:application_component, "ApplicationComponent"],
        [:application_collaboration, "ApplicationCollaboration"],
        [:application_interface, "ApplicationInterface"],
        [:application_function, "ApplicationFunction"],
        [:application_interaction, "ApplicationInteraction"],
        [:application_process, "ApplicationProcess"],
        [:application_event, "ApplicationEvent"],
        [:application_service, "ApplicationService"],
        [:data_object, "DataObject"],
        [:node, "Node"],
        [:device, "Device"],
        [:technology_collaboration, "TechnologyCollaboration"],
        [:technology_interface, "TechnologyInterface"],
        [:path, "Path"],
        [:communication_network, "CommunicationNetwork"],
        [:technology_function, "TechnologyFunction"],
        [:technology_interaction, "TechnologyInteraction"],
        [:technology_event, "TechnologyEvent"],
        [:artifact, "Artifact"],
        [:equipment, "Equipment"],
        [:facility, "Facility"],
        [:distribution_network, "DistributionNetwork"],
        [:material, "material"],
        [:stakeholder, "Stakeholder"],
        [:driver, "Driver"],
        [:assessment, "Assessment"],
        [:goal, "Goal"],
        [:outcome, "Outcome"],
        [:principle, "Principle"],
        [:requirement, "Requirement"],
        [:constraint, "Constraint"],
        [:meaning, "Meaning"],
        [:value, "Value"],
        [:resource, "Resource"],
        [:capability, "Capability"],
        [:course_of_action, "CourseOfAction"],
        [:value_stream, "ValueStream"],
        [:work_package, "WorkPackage"],
        [:deliverable, "Deliverable"],
        [:implementation_event, "ImplementationEvent"],
        [:plateau, "Plateau"],
        [:gap, "Gap"],
        [:and_junction, "AndJunction"],
        [:or_junction, "OrJunction"]
      ].freeze

      PARENTING_ELEMENT_SETS = [
        [:group, "Group"],
        [:location, "Location"],
        [:system_software, "SystemSoftware"],
        [:technology_process, "TechnologyProcess"],
        [:technology_service, "TechnologyService"]
      ].freeze

      def self.define_parent_element_method(name, ele_kind)
        class_eval(<<-RUBY_CODE)
          def #{name}(element_name, element_id = "e-" + SecureRandom.uuid, &blk)
            ele = #{ele_kind}.new(@association_registry, @element_lookup, element_name, element_id, &blk)
            @element_lookup.add_element(ele)
            @children << ele
            ele
          end
        RUBY_CODE
      end

      PARENTING_ELEMENT_SETS.each do |pe_item|
        define_parent_element_method(pe_item[0], pe_item[1])
      end

      REAL_ELEMENT_SET.each do |re_item|
        define_real_element_method(re_item[0], re_item[1])
      end
    end
  end
end