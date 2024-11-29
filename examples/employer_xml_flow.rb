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
  gdb = technology_service "GlueDB"
  hbx_e = technology_service "hbx_enterprise" do
    eddl = technology_service("EmployerDigestDropListener")
    edlt = technology_service("EmployerLegacyDigestTransformer")
    eldl = technology_service "EmployerLegacyDigestListener"
    eldppl = technology_service "EmployerDigestPaymentProcessorListener"
  end
  r_mq = system_software "RabbitMQ" do
    f_ex = technology_interface "<client>.<environment>.e.fanout.events"
    t_ex = technology_interface "<client>.<environment>.e.topic.events"
    eddl_q = technology_interface "<client>.<environment>.q.hbx_enterprise.employer_digest_drop_listener"
    edlt_q = technology_interface "<client>.<environment>.q.hbx_enterprise.employer_legacy_digest_transformer"
    eldl_q = technology_interface "<client>.<environment>.q.hbx_enterprise.employer_legacy_digest_listener"
    eldppl_q = technology_interface "<client>.<environment>.q.hbx_enterprise.employer_digest_payment_processor_listener"
  end

  all_messages = path "All Messages"
  r_key = path "info.events.trading_partner.employer_digest.published"
  eldl_rk = path "info.events.trading_partner.legacy_employer_digest.published"

  flow f_ex, all_messages
  flow all_messages, t_ex
  flow t_ex, r_key
  flow r_key, eddl_q
  flow r_key, edlt_q

  flow t_ex, eldl_rk
  flow eldl_rk, eldl_q
  flow eldl_q, eldl

  flow eldl_rk, eldppl_q
  flow eldppl_q, eldppl

  nfp_sftp = technology_service "NFP SFTP"
  sftp_upload = path "SFTP Upload"

  flow eldppl, sftp_upload
  flow sftp_upload, nfp_sftp

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

  flow eddl_q, eddl
  flow edlt_q, edlt
  flow eddl, s_req
  flow s_req, composite

  pevdx = technology_interaction "Publish Employer V2 Digest XML"
  peldx = technology_interaction "Publish Employer Legacy Digest XML"

  flow gdb, pevdx
  flow pevdx, f_ex
  flow edlt, peldx
  flow peldx, f_ex

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

File.open("employer_xml_flow.xml", "wb") do |f|
  f.puts model.to_xml
end