extends Node

var music_player : AudioStreamPlayer
var sfx_player : AudioStreamPlayer

const bkg := preload("res://audio/DavidKBD - Pink Bloom Pack - 02 - Portal to Underworld.ogg")
const slash := preload("res://audio/slash.mp3")

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	sfx_player = AudioStreamPlayer.new()
	
	add_child(music_player)
	add_child(sfx_player)
	
func play_music(stream: AudioStream) -> void:
	if music_player.stream == stream and music_player.playing:
		return
		
	music_player.stream = stream
	music_player.volume_db = -25.0
	music_player.play()
	
func play_bkg() -> void:
	music_player.stream = bkg
	music_player.volume_db = -25.0
	music_player.play()

func play_slash() -> void:
	play_sfx(slash)
	
func stop_music() -> void:
	music_player.stop()
	
func play_sfx(stream: AudioStream) -> void:
	stream.loop = false
	
	sfx_player.stream = stream
	sfx_player.volume_db = -30.0
	sfx_player.play()
	
func stop_sfx()->void:
	sfx_player.stop()
