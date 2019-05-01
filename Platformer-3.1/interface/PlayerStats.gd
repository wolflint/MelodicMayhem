extends VBoxContainer

# Game elements
onready var GAME = get_tree().get_root().get_node("Game")
onready var LEVEL = GAME.get_node("Level")

# UI elements
onready var hp_bar = $HealthBar
onready var music_bar = $MusicBar
onready var exp_bar = $ExperienceBar
onready var score_lbl = $Score
onready var effect_lbl = $EffectTime

func initialise():
	exp_bar.initialize(LEVEL.player.experience, LEVEL.player.experience_required, [LEVEL.player])
	hp_bar.initialize(LEVEL.player.health.health, LEVEL.player.health.max_health, [LEVEL.player])
	music_bar.initialize(LEVEL.player.current_music, LEVEL.player.max_music, [LEVEL.player])