require_relative "../test_helper"

class TestArchiDsl < Minitest::Test
  def test_initial_model
    person = nil
    email = nil

    model = ArchiDsl.model "enroll" do
      user = application_component "User"
      pdg = group "Person Document" do
        person = application_component "Person"
        email = application_component "Email"
      end

      composition person, email

      association person, user

      diagram "Items" do
        node pdg
        node person
        node email
        node user
      end
    end

    puts model.to_xml.to_xml
  end
end
