extends Control

@onready var lobby_list_container = $LobbyListContainer
var network = ENetMultiplayerPeer.new()

func _ready():
	connect_to_server()

func connect_to_server():
	var error = network.create_client("127.0.0.1", 4242)
	if error == OK:
		multiplayer.multiplayer_peer = network
		print("Client connecting to server...")
		network.connect("connected_to_server", _on_connected_to_server)
		network.connect("connection_failed", _on_connection_failed)
	else:
		print("Failed to create client: ", error)

func _on_connected_to_server():
	print("Connected to server from lobby screen!")
	request_lobby_list()

func _on_connection_failed():
	print("Failed to connect to server!")
	lobby_list_container.get_node("LobbyLabel").text = "Connection failed!"

func request_lobby_list():
	print("Requesting lobby list...")
	rpc_id(1, "request_lobby_list")  # 1 is the server’s ID

@rpc("any_peer")
func receive_lobby_list(lobby_data):
	print("Received lobby data: ", lobby_data)
	lobby_list_container.get_node("LobbyLabel").text = str(lobby_data)
