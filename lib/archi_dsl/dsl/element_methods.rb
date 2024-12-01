module ArchiDsl
  module Dsl
    module ElementMethods
      def self.define_real_element_method(name, ele_kind)
        class_eval(<<-RUBY_CODE)
          def #{name}(element_name, **kwargs, &blk)
            ele = RealElement.new(@association_registry, "#{ele_kind}", element_name, **kwargs, &blk)
            @element_lookup.add_element(ele)
            @children << ele
            ele
          end
        RUBY_CODE
      end

      MODEL_ELEMENT_SET = [
        [:business_actor, "Business::BusinessActor"],
        [:business_role, "Business::BusinessRole"],
        [:business_collaboration, "Business::BusinessCollaboration"],
        [:business_interface, "Business::BusinessInterface"],
        [:business_process, "Business::BusinessProcess"],
        [:business_function, "Business::BusinessFunction"],
        [:business_interaction, "Business::BusinessInteraction"],
        [:business_event, "Business::BusinessEvent"],
        [:business_service, "Business::BusinessService"],
        [:business_object, "Business::BusinessObject"],
        [:contract, "Business::Contract"],
        [:representation, "Business::Representation"],
        [:product, "Business::Product"],
        [:application_component, "Application::ApplicationComponent"],
        [:application_collaboration, "Application::ApplicationCollaboration"],
        [:application_interface, "Application::ApplicationInterface"],
        [:application_function, "Application::ApplicationFunction"],
        [:application_interaction, "Application::ApplicationInteraction"],
        [:application_process, "Application::ApplicationProcess"],
        [:application_event, "Application::ApplicationEvent"],
        [:application_service, "Application::ApplicationService"],
        [:data_object, "Application::DataObject"],
        [:equipment, "Physical::Equipment"],
        [:facility, "Physical::Facility"],
        [:material, "Physical::Material"]
      ].freeze

      REAL_ELEMENT_SET = [
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
        [:distribution_network, "DistributionNetwork"],
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

      def self.define_model_element_method(name, ele_kind)
        class_eval(<<-RUBY_CODE)
          def #{name}(element_name, **kwargs, &blk)
            ele = #{ele_kind}.new(@association_registry, @element_lookup, element_name, **kwargs)
            @children << ele
            ele
          end
        RUBY_CODE
      end

      def self.define_parent_element_method(name, ele_kind)
        class_eval(<<-RUBY_CODE)
          def #{name}(element_name, **kwargs, &blk)
            ele = #{ele_kind}.new(@association_registry, @element_lookup, element_name, **kwargs, &blk)
            @element_lookup.add_element(ele)
            @children << ele
            ele
          end
        RUBY_CODE
      end

      MODEL_ELEMENT_SET.each do |pe_item|
        define_model_element_method(pe_item[0], pe_item[1])
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