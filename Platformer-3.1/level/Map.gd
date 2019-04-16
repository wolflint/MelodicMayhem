extends TileMap

# GAME LAYOUT
onready var GAME = get_tree().get_root().get_node("Game")
onready var LEVEL = GAME.get_node("Level")

signal score_changed(score)
signal personal_best_changed(personal_best)

export (bool) var is_dungeon = false
export (String) var MAP_NAME
var highscore : int
var personal_best : int
var score = 0

func _ready():
	connect("score_changed", GAME, "_on_Map_score_changed", [score])
	connect("personal_best_changed", GAME, "_on_Map_personal_best_changed", [personal_best])

func _update_highscore(new_score):
	if new_score > highscore:
		highscore = new_score
	if new_score > personal_best:
		personal_best = new_score
		emit_signal("personal_best_changed", personal_best)

func _on_enemy_died(score_worth):
	score += score_worth
	emit_signal("score_changed", score)
	_update_highscore(score)
	print(score)

### HIGHSCORE SYSTEM ###
func get_score_data():
	return {
		"filename": filename,
		"parent": get_parent().get_path(),
		"properties": {
			"MAP_NAME": MAP_NAME,
			"highscore": highscore,
		}
	}

func get_save_data():
	return {
		"filename": filename,
		"parent": get_parent().get_path(),
		"properties": {
			"MAP_NAME": MAP_NAME,
			"personal_best": personal_best,
		}
	}