require "archi_dsl"

model = ArchiDsl.model "Employer V2 XML Process" do
  f_ex = nil
  t_ex = nil
  eddl = nil
  eddl_q = nil
  composite = nil
  o_b2b = nil
  o_soa = nil
  edlt = nil
  edlt_q = nil
  eldl = nil
  eldl_q = nil
  eldl_rk = nil
  eldppl_q = nil
  eldppl = nil
  gdb = technology_service "GlueDB", folder: "GlueDB"
  hbx_e = technology_service "hbx_enterprise", folder: "hbx_enterprise" do
    eddl = technology_service("EmployerDigestDropListener", folder: "hbx_enterprise")
    edlt = technology_service("EmployerLegacyDigestTransformer", folder: "hbx_enterprise")
    eldl = technology_service "EmployerLegacyDigestListener", folder: "hbx_enterprise"
    eldppl = technology_service "EmployerDigestPaymentProcessorListener", folder: "hbx_enterprise"
  end
  r_mq = system_software "RabbitMQ", folder: "rabbit_mq" do
    f_ex = technology_service "<client>.<environment>.e.fanout.events", folder: "rabbit_mq"
    t_ex = technology_service "<client>.<environment>.e.topic.events", folder: "rabbit_mq"
    eddl_q = technology_service "<client>.<environment>.q.hbx_enterprise.employer_digest_drop_listener", folder: "rabbit_mq"
    edlt_q = technology_service "<client>.<environment>.q.hbx_enterprise.employer_legacy_digest_transformer", folder: "rabbit_mq"
    eldl_q = technology_service "<client>.<environment>.q.hbx_enterprise.employer_legacy_digest_listener", folder: "rabbit_mq"
    eldppl_q = technology_service "<client>.<environment>.q.hbx_enterprise.employer_digest_payment_processor_listener", folder: "rabbit_mq"
  end

  all_messages = path "All Messages", folder: "rabbit_mq"
  r_key = path "info.events.trading_partner.employer_digest.published", folder: "rabbit_mq"
  eldl_rk = path "info.events.trading_partner.legacy_employer_digest.published", folder: "rabbit_mq"

  flow f_ex, all_messages, folder: "rabbit_mq"
  flow all_messages, t_ex, folder: "rabbit_mq"
  flow t_ex, r_key, folder: "rabbit_mq"
  flow r_key, eddl_q, folder: "rabbit_mq"
  flow r_key, edlt_q, folder: "rabbit_mq"

  flow t_ex, eldl_rk, folder: "rabbit_mq"
  flow eldl_rk, eldl_q, folder: "rabbit_mq"
  flow eldl_q, eldl, folder: "rabbit_mq"

  flow eldl_rk, eldppl_q, folder: "rabbit_mq"
  flow eldppl_q, eldppl, folder: "service interactions"

  nfp_sftp = technology_service "NFP SFTP"
  sftp_upload = path "SFTP Upload", folder: "service interactions"

  flow eldppl, sftp_upload, folder: "service interactions"
  flow sftp_upload, nfp_sftp, folder: "service interactions"

  wl_as = system_software "Weblogic", folder: "weblogic" do
    o_soa = system_software "Oracle SOA", folder: "weblogic" do
      composite = technology_service "GroupXMLV2CarrCmpService", folder: "weblogic/soa"
    end
    o_b2b = technology_service "Oracle B2B", folder: "weblogic/b2b"
  end

  b2bm = technology_interaction "B2B Message", folder: "weblogic/soa"

  s_req = path "SOAP Request", folder: "service interactions"

  flow composite, b2bm, folder: "weblogic"
  flow b2bm, o_b2b, folder: "weblogic"

  flow eddl_q, eddl, folder: "service interactions"
  flow edlt_q, edlt, folder: "service interactions"
  flow eddl, s_req, folder: "service interactions"
  flow s_req, composite, folder: "service interactions"

  pevdx = technology_interaction "Publish Employer V2 Digest XML", folder: "service interactions"
  peldx = technology_interaction "Publish Employer Legacy Digest XML", folder: "service interactions"

  flow gdb, pevdx, folder: "service interactions"
  flow pevdx, f_ex, folder: "service interactions"
  flow edlt, peldx, folder: "service interactions"
  flow peldx, f_ex, folder: "service interactions"

  evdx = application_process "Cut Employer Event Batch", folder: "GlueDB"
  er = application_event "Receive Event:\n'trading_partner.employer_digest.requested'", folder: "GlueDB"
  spee = application_process "Select Pending Employer Events From Database", folder: "GlueDB"
  ccsd = application_process "Batch Events\ninto Carrier-Specific Digests", folder: "GlueDB"
  dbee = application_process "Delete Batched\nEmployer Events\nfrom Database", folder: "GlueDB"
  nte = application_process "Produce Enrollment\nTransmission Notification\nEvents", folder: "GlueDB"
  eiet_ok = application_event "Publish Event:\n'employer.binder_enrollments_transmission_authorized'", folder: "ACAPI Events"
  ert_ok = application_event "Publish Event:\n'employer.benefit_coverage_renewal_application_eligible'", folder: "ACAPI Events"
  employer_v2_event = application_event "Publish Event:\n'trading_partner.employer_digest.published'", folder: "ACAPI Events"
  special_events_decision = or_junction "Did we batch a 'special' event?", folder: "GlueDB"
  ev2xml = data_object "V2 Employer XML", folder: "XML"
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
  triggering er, spee, folder: "GlueDB"
  triggering ccsd, employer_v2_event, folder: "GlueDB"
  access employer_v2_event, ev2xml, accessType: "Write", label: "event format", folder: "XML"

  diagram "Employer XML V2 Flow" do
    node gdb
    node pevdx
    node peldx
    node s_req
    node nfp_sftp
    node sftp_upload
    layout_link eldppl_q, sftp_upload
    layout_link eldl, sftp_upload
    group r_mq do
      node f_ex
      node all_messages
      node t_ex
      node r_key
      node eddl_q
      node edlt_q
      node eldl_rk
      node eldl_q
      node eldppl_q
    end
    group hbx_e do
      node eddl
      node edlt
      node eldl
      node eldppl
    end
    group wl_as do
      group o_soa do
        node composite
      end
      node o_b2b
      node b2bm
    end
  end

  diagram "Employer Digest Generation Flow" do
    node employer_v2_event
    comm = nil
    layout_container do
    group evdx do
      node er
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
        comm = comment "These Events Request\nTransmission of Enrollments\nfrom Enroll to GlueDB"
      end
    end
    comment_link comm, eiet_ok
    comment_link comm, ert_ok
    node ev2xml
  end
end

model.preview_diagram("Employer Digest Generation Flow", "employer_xml_flow.png")

File.open("employer_xml_flow.xml", "wb") do |f|
  f.puts model.to_xml
end