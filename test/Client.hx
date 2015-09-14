
import enet.ENet;

class Client {
        
    static function main() {

        var adr:ENetAddress = null;
        var client:ENetHost = null;
        var peer:ENetPeer = null;
        var event:ENetEvent = null;
        var eventStatus = 1;

        var msg = "";
    	
    	if (ENet.initialize() != 0) {
    		trace("An error occurred while initializing ENet.");
    		return;
    	}    	

    	client = ENet.host_create(untyped 0, 1, 2, Std.int(57600 / 8), Std.int(14400 / 8));
    	if (client == null) {
    		trace("An error occurred while trying to create an ENet client.");
    		ENet.deinitialize();
    		return;
    	}

    	trace(ENet.address_set_host(cpp.Pointer.fromHandle(adr), "localhost"));
        adr.port = 1234;

        peer = ENet.host_connect(client, cpp.Pointer.fromHandle(adr), 2, 0);

        if (peer == null) {
            trace("No available peers for initializing an ENet connection");
            ENet.deinitialize();
            return;
        }

        if (ENet.host_service (client, cpp.Pointer.fromHandle(event), 5000) > 0 &&
            event.type == ENetEventType.ENET_EVENT_TYPE_CONNECT) {
            trace("Connection to server succeeded.");
        }
        else
        {
            /* Either the 5 seconds are up or a disconnect event was */
            /* received. Reset the peer in the event the 5 seconds   */
            /* had run out without any significant event.            */
            ENet.peer_reset(peer);
            trace("Connection to server failed.");
            ENet.host_destroy(client);
            ENet.deinitialize();
            return;
        }

        while(true) {
            eventStatus = ENet.host_service(client, cpp.Pointer.fromHandle(event), 0);
            trace(eventStatus);
            if (eventStatus > 0) {
                switch(event.type) {
                    case ENetEventType.ENET_EVENT_TYPE_CONNECT:
                        trace('Client got a new connection from $event.peer.address.host');
                    case ENetEventType.ENET_EVENT_TYPE_RECEIVE:
                        trace('Client received message from server: $event.packet.data');
                        ENet.packet_destroy(event.packet);
                    case ENetEventType.ENET_EVENT_TYPE_DISCONNECT:
                        trace('$event.peer.data disconnected');
                        //event.peer.data = null;
                    default:
                }
            }

            msg = "" + Std.random(100);
            var packet = ENet.packet_create(cast msg, msg.length+1, ENetPacketFlag.ENET_PACKET_FLAG_RELIABLE);
            trace(ENet.peer_send(peer, 0, packet));
        }

    	ENet.host_destroy(client);

    	ENet.deinitialize();
    }
}