require "archi_dsl"

model = ArchiDsl.model "ACAPI Messaging" do
  f_ex = nil
  t_ex = nil
  d_ex = nil
  r_ex = nil
  rc_queue = nil
  es_queue = nil
  event_publication = technology_interaction "Event Message Publication", folder: "message_publication"
  request_publication = technology_interaction "Request Message Publication", folder: "message_publication"

  r_mq = system_software "RabbitMQ", folder: "rabbit_mq" do
    f_ex = technology_service "Fanout Exchange:\n<client>.<environment>.e.fanout.events", folder: "rabbit_mq"
    t_ex = technology_service "Topic Exchange:\n<client>.<environment>.e.topic.events", folder: "rabbit_mq"
    d_ex = technology_service "Direct Exchange:\n<client>.<environment>.e.direct.events", folder: "rabbit_mq"
    r_ex = technology_service "Direct Exchange:\n<client>.<environment>.e.direct.requests", folder: "rabbit_mq"
    rc_queue = technology_service "Request Client Queue", folder: "rabbit_mq"
    es_queue = technology_service "Event Subscriber Queue", folder: "rabbit_mq"
  end

  e_subscriber = application_component "Event Subscriber", folder: "acapi_event_subscriber"
  r_subscriber = application_component "Request Subscriber", folder: "acapi_request_subscriber"
  cesbaq_interaction = technology_interaction "Create\nEvent\nSubscriber\nBinding and Queue", folder: "acapi_event_subscriber"
  crqbaq_interaction = technology_interaction "Create\nRequest\nClient\nBinding and Queue", folder: "acapi_request_subscriber"

  event_subscriber_binding = path "Event Client Binding", folder: "rabbit_mq"
  e2e_binding = path "Exchange to Exchange Binding", folder: "rabbit_mq"
  rc_binding = path "Request Client Binding", folder: "rabbit_mq"

  flow event_publication, f_ex, folder: "message_publication"
  flow request_publication, r_ex, folder: "message_publication"
  flow r_ex, rc_binding, folder: "rabbit_mq"
  flow rc_binding, rc_queue, folder: "rabbit_mq"
  flow f_ex, e2e_binding, folder: "rabbit_mq"
  flow e2e_binding, t_ex, folder: "rabbit_mq"
  flow e2e_binding, d_ex, folder: "rabbit_mq"
  flow t_ex, event_subscriber_binding, folder: "rabbit_mq"
  flow d_ex, event_subscriber_binding, folder: "rabbit_mq"
  flow event_subscriber_binding, es_queue, folder: "rabbit_mq"
  flow es_queue, e_subscriber, folder: "acapi_event_subscriber"
  flow rc_queue, r_subscriber, folder: "acapi_request_subscriber"

  triggering e_subscriber, cesbaq_interaction, folder: "acapi_event_subscriber"
  triggering r_subscriber, crqbaq_interaction, folder: "acapi_request_subscriber"
  serving event_subscriber_binding, cesbaq_interaction, folder: "acapi_event_subscriber"
  serving es_queue, cesbaq_interaction, folder: "acapi_event_subscriber"
  serving rc_binding, crqbaq_interaction, folder: "acapi_request_subscriber"
  serving rc_queue, crqbaq_interaction, folder: "acapi_request_subscriber"

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