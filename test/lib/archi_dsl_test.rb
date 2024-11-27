require_relative "../test_helper"

class TestArchiDsl < Minitest::Test
  def test_component_model
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

    model.to_xml
  end

  def test_employer_model
    f_ex = nil
    t_ex = nil
    eddl = nil
    q = nil
    composite = nil
    o_b2b = nil
    o_soa = nil

    model = ArchiDsl.model "Employer V2 XML Process" do
      gdb = technology_service "GlueDB"
      hbx_e = technology_service "hbx_enterprise" do
        eddl = technology_service("EmployerDigestDropListener")
      end
      r_mq = system_software "RabbitMQ" do
        f_ex = technology_interface "<client>.<environment>.e.fanout.events"
        t_ex = technology_interface "<client>.<environment>.e.topic.events"
        q = technology_interface "<client>.<environment>.q.hbx_enterprise.employer_digest_drop_listener"
      end

      all_messages = path "All Messages"
      r_key = path "info.events.trading_partner.employer_digest.published"

      flow f_ex, all_messages
      flow all_messages, t_ex
      flow t_ex, r_key
      flow r_key, q

      wl_as = system_software "Weblogic" do
        o_soa = system_software "Oracle SOA" do
          composite = technology_service "GroupXMLV2CarrCmpService"
        end
        o_b2b = technology_service "Oracle B2B"
      end

      b2bm = technology_interaction "B2B Message"

      s_req = path "SOAP Request"

      flow composite, b2bm
      flow b2bm, o_b2b

      flow q, eddl
      flow eddl, s_req
      flow s_req, composite

      pevdx = technology_interaction "Publish Employer V2 Digest XML"

      flow gdb, pevdx
      flow pevdx, f_ex

      diagram "Employer XML V2 Flow" do
        group hbx_e do
          node eddl
        end
        group r_mq do
          node f_ex
          node all_messages
          node t_ex
          node r_key
          node q
        end
        group wl_as do
          group o_soa do
            node composite
          end
          node o_b2b
          node b2bm
        end
        node gdb
        node pevdx
        node s_req
      end
    end

    model.to_xml
  end
end
