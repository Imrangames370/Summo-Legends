extends LineEdit


func _on_Player_Name_Editor_text_changed(new_text: String):
	# Update the player's name display
	VariableDock.player_1_name_text = new_text
	print(new_text, "new_text player name")
