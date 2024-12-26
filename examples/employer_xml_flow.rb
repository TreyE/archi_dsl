require "archi_dsl"

model = ArchiDsl.model "Employer V2 XML Process" do

  # HBX Enterprise
  hbx_e = application_component "hbx_enterprise", folder: "hbx_enterprise"
  eddl = application_component("EmployerDigestDropListener", folder: "hbx_enterprise")
  eldt = application_component("EmployerLegacyDigestTransformer", folder: "hbx_enterprise")
  eldppl = application_component "EmployerDigestPaymentProcessorListener", folder: "hbx_enterprise"

  nfp_sftp = application_component "NFP SFTP", folder: "NFP"

  wl_as = application_component "Weblogic", folder: "weblogic"
  o_soa = application_component "Oracle SOA", folder: "weblogic"
  composite = application_component "GroupXMLV2CarrCmpService", folder: "weblogic"
  o_b2b = application_component "Oracle B2B", folder: "weblogic"

  b2bm = data_object "B2B Message", folder: "weblogic"
  uvx = data_object "Employer V1 XML", folder: "NFP"

  access composite, b2bm, folder: "weblogic", accessType: "Write"
  access o_b2b, b2bm, folder: "weblogic", accessType: "Read"

  tpedp = application_event "Recieve Event:\n'trading_partner.employer_digest.published'", folder: "ACAPI Events"
  triggering tpedp, eddl, folder: "ACAPI Events"
  triggering tpedp, eldt, folder: "ACAPI Events"

  pldp = application_event "Publish Event:\n'trading_partner.legacy_employer_digest.published'", folder: "ACAPI Events"
  rldp = application_event "Recieve Event:\n'trading_partner.legacy_employer_digest.published'", folder: "ACAPI Events"

  sm = data_object "SOAP Message", folder: "weblogic"

  triggering pldp, rldp, folder: "ACAPI Events"
  triggering rldp, eldppl, folder: "ACAPI Events"
  triggering eldt, pldp, folder: "ACAPI Events"

  access eddl, sm, accessType: "Write", folder: "weblogic"
  access composite, sm, accessType: "Read", folder: "weblogic"

  access eldppl, uvx, accessType: "Write", folder: "NFP"
  access nfp_sftp, uvx, accessType: "Read", folder: "NFP"

  diagram "Employer Digest Generation Flow - Hbx Enterprise", folder: "hbx_enterprise" do
    node tpedp
    layout_container do
      group hbx_e do
          node eddl
        layout_container do
          node eldt
          node eldppl
          node pldp
          node rldp
        end
      end

      layout_container do
        node uvx
        layout_container cluster: false, rank: "min" do
          node nfp_sftp
        end
      end

      layout_container do
        node sm
        group wl_as do
          layout_container do
            group o_soa do
              node composite
            end
            node b2bm
            layout_container cluster: false, rank: "min" do
              node o_b2b
            end
          end
        end
      end
    end
    layout_link eddl, composite
  end

  # GlueDB items - employer XML digest

  evdx = application_process "Cut Employer Event Batch", folder: "GlueDB"
  er = application_event "Receive Event:\n'trading_partner.employer_digest.requested'", folder: "ACAPI Events"
  spee = application_process "Select Pending Employer Events From Database", folder: "GlueDB"
  ccsd = application_process "Batch Events\ninto Carrier-Specific Digests", folder: "GlueDB"
  dbee = application_process "Delete Batched\nEmployer Events\nfrom Database", folder: "GlueDB"
  nte = application_process "Produce Enrollment\nTransmission Notification\nEvents", folder: "GlueDB"
  eiet_ok = application_event "Publish Event:\n'employer.binder_enrollments_transmission_authorized'", folder: "ACAPI Events"
  ert_ok = application_event "Publish Event:\n'employer.benefit_coverage_renewal_application_eligible'", folder: "ACAPI Events"
  employer_v2_event = application_event "Publish Event:\n'trading_partner.employer_digest.published'", folder: "ACAPI Events"
  special_events_decision = or_junction "Did we batch a 'special' event?", folder: "GlueDB"
  composition evdx, dbee, folder: "GlueDB"
  composition evdx, ccsd, folder: "GlueDB"
  composition evdx, nte, folder: "GlueDB"
  triggering nte, eiet_ok, folder: "ACAPI Events"
  triggering nte, ert_ok, folder: "ACAPI Events"
  flow spee, ccsd, folder: "GlueDB"
  flow ccsd, special_events_decision, label: "Did we batch a 'special' event?", folder: "GlueDB"
  flow special_events_decision, nte, label: "Yes", folder: "GlueDB"
  flow special_events_decision, dbee, label: "No", folder: "GlueDB"
  flow nte, dbee, folder: "GlueDB"
  triggering ccsd, employer_v2_event, folder: "GlueDB"

  gdb_eddl = application_component "Listeners::EmployerDigestDropListener", folder: "GlueDB"
  serving gdb_eddl, evdx, folder: "GlueDB"
  triggering er, gdb_eddl, folder: "GlueDB"

  diagram "Employer Digest Generation Flow - GlueDB", folder: "GlueDB" do
    node er
    node gdb_eddl
    comm_1 = nil
    node employer_v2_event
    group evdx do
      node spee
      node ccsd
      layout_container do
        layout_container cluster: false, rank: "max" do
          node special_events_decision
          node dbee
        end
        node nte
      end
    end
    layout_container do
      node eiet_ok
      node ert_ok
    end
    layout_container cluster: false, rank: "min" do
      comm_1 = comment "These events request\ntransmission of enrollments\nfrom Enroll to GlueDB"
    end
    comm_2 = comment "At this point the event contains\na V2 Employer XML Payload.\n\nThe next stop for this event is hbx_enterprise."

    comment_link comm_2, employer_v2_event
    comment_link comm_1, eiet_ok
    comment_link comm_1, ert_ok

    layout_link gdb_eddl, spee
  end
end

# puts model.debug_diagram("Employer Digest Generation Flow")

model.preview_diagram("Employer Digest Generation Flow - Hbx Enterprise", "employer_xml_flow.png")

File.open("employer_xml_flow.xml", "wb") do |f|
  f.puts model.to_xml
end