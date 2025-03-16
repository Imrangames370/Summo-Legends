extends Node

var network = ENetMultiplayerPeer.new()
var port = 4242
var max_players = 20
var lobbies = {}  # Dictionary to store lobbies

func _ready():
	start_server()
	create_lobby("Lobby 1",4 )

func start_server():
	network.create_server(port, max_players)
	multiplayer.multiplayer_peer = network
	print("Server started on port ", port)
	network.connect("peer_connected", _on_peer_connected)
	network.connect("peer_disconnected", _on_peer_disconnected)

func _on_peer_connected(peer_id):
	print("Player connected: ", peer_id)
	# For now, just log the connection—lobbies come next!

func _on_peer_disconnected(peer_id):
	print("Player disconnected: ", peer_id)
	# Later, we’ll remove them from lobbies here

func create_lobby(lobby_name, max_players_per_lobby):
	lobbies[lobby_name] = {
		"max_players": max_players_per_lobby,
		"current_players": 0,
		"player_ids": []
	}
	print("Created lobby: ", lobby_name, " with max players: ", max_players_per_lobby)

func get_lobby_list():
	return lobbies

# In server.gd, update this function:
@rpc("any_peer")
func request_lobby_list():
	var peer_id = multiplayer.get_remote_sender_id()
	print("Client ", peer_id, " requested lobby list")
	rpc_id(peer_id, "receive_lobby_list", get_lobby_list())

@rpc("any_peer")
func receive_lobby_list(lobby_data):
	pass  # Client will override this
