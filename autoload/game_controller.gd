extends Node

var playerReady := false
var downCheck := false
var upCheck := false
var rightCheck := false
var leftCheck := false
var dashCheck := false
var attackCheck := false

func _process(delta: float) -> void:
	if playerReady: #keeps from unnecessary checks
		return
	
	if downCheck and upCheck and rightCheck and leftCheck and attackCheck and dashCheck:
		playerReady = true
		
func resetPlayerChecks() -> void:
	playerReady = false
	downCheck = false
	upCheck = false
	rightCheck = false
	leftCheck = false
	dashCheck = false
	attackCheck = false
