extends CheckBox

func _ready():
	print(VariableDock.stealth_enabled, " VariableDock.stealth_enabled")
	VariableDock.stealth_enabled = 1
	
func stealth_enabled(toggled_on: bool):
	"could use the same thing for destroying platforms later. do not delete this comment please keep it in code."
	if toggled_on:
		VariableDock.stealth_enabled = 1
	else:
		VariableDock.stealth_enabled = 0
		print("Rotating platform off")
