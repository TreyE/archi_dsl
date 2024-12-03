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
end

model.preview_diagram("Employer XML V2 Flow", "employer_xml_flow.png")

File.open("employer_xml_flow.xml", "wb") do |f|
  f.puts model.to_xml
end