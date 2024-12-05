require "archi_dsl"

model = ArchiDsl.model "ACAPI Messaging" do
  f_ex = nil
  t_ex = nil
  d_ex = nil
  r_ex = nil
  rc_queue = nil
  es_queue = nil
  event_publication = technology_interaction "Event Message Publication"
  request_publication = technology_interaction "Request Message Publication"

  r_mq = system_software "RabbitMQ", folder: "rabbit_mq" do
    f_ex = technology_service "Fanout Exchange:\n<client>.<environment>.e.fanout.events", folder: "rabbit_mq"
    t_ex = technology_service "Topic Exchange:\n<client>.<environment>.e.topic.events", folder: "rabbit_mq"
    d_ex = technology_service "Direct Exchange:\n<client>.<environment>.e.direct.events", folder: "rabbit_mq"
    r_ex = technology_service "Direct Exchange:\n<client>.<environment>.e.direct.requests"
    rc_queue = technology_service "Request Client Queue"
    es_queue = technology_service "Event Subscriber Queue"
  end

  e_subscriber = application_component "Event Subscriber"
  r_subscriber = application_component "Request Subscriber"
  cesbaq_interaction = technology_interaction "Create\nEvent\nSubscriber\nBinding and Queue"
  crqbaq_interaction = technology_interaction "Create\nRequest\nClient\nBinding and Queue"

  event_subscriber_binding = path "Event Client Binding"
  e2e_binding = path "Exchange to Exchange Binding"
  rc_binding = path "Request Client Binding"

  flow event_publication, f_ex
  flow request_publication, r_ex
  flow r_ex, rc_binding
  flow rc_binding, rc_queue
  flow f_ex, e2e_binding
  flow e2e_binding, t_ex
  flow e2e_binding, d_ex
  flow t_ex, event_subscriber_binding
  flow d_ex, event_subscriber_binding
  flow event_subscriber_binding, es_queue
  flow es_queue, e_subscriber
  flow rc_queue, r_subscriber

  triggering e_subscriber, cesbaq_interaction
  triggering r_subscriber, crqbaq_interaction
  serving event_subscriber_binding, cesbaq_interaction
  serving es_queue, cesbaq_interaction
  serving rc_binding, crqbaq_interaction
  serving rc_queue, crqbaq_interaction

  diagram "ACAPI Message Routing" do
    group r_mq do
      layout_container do
        node t_ex
        node d_ex
        node r_ex
      end
      layout_container do
        layout_container cluster: false, rank: "max" do
          node crqbaq_interaction
        end
        layout_container do
          node rc_binding
          node rc_queue
        end
      end
      layout_container do
        layout_container cluster: false, rank: "max" do
          node cesbaq_interaction
        end
        layout_container do
          node event_subscriber_binding
          node es_queue
        end
      end
      node e2e_binding
      node f_ex
    end
    layout_container do
      node event_publication
      node request_publication
    end
    layout_container cluster: false, rank: "same" do
      node e_subscriber
      node r_subscriber
    end
  end
end

# puts model.debug_diagram("ACAPI Message Routing")

model.preview_diagram("ACAPI Message Routing", "acapi.png")

File.open("acapi.xml", "wb") do |f|
  f.puts model.to_xml
end