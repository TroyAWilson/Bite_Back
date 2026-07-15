extends Node

var music_player : AudioStreamPlayer
var sfx_player : AudioStreamPlayer

const bkg := preload("res://audio/DavidKBD - Pink Bloom Pack - 02 - Portal to Underworld.ogg")
const slash := preload("res://audio/slash.mp3")
const swing := preload("res://audio/swing.mp3")
const steps := preload("res://audio/steps.mp3")
const bossDie := preload("res://audio/BossDieSound.mp3")
const victory := preload("res://audio/victory.mp3")
const defeat := preload("res://audio/defeat.mp3")
const menu := preload("res://audio/DavidKBD - Pink Bloom Pack - 08 - Lost Spaceship's Signal.ogg")
const slam := preload("res://audio/slam.mp3")
const whoosh := preload("res://audio/whoosh.mp3")
const splat := preload("res://audio/splat.mp3")

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	sfx_player = AudioStreamPlayer.new()
	
	add_child(music_player)
	add_child(sfx_player)
	
func play_music(stream: AudioStream, volume : float = -25.0, looping : bool = true) -> void:
	if music_player.stream == stream and music_player.playing:
		return
		
	stream.loop = looping
	music_player.stream = stream
	music_player.volume_db = volume
	music_player.play()
	
func play_bkg() -> void:
	music_player.stream = bkg
	music_player.volume_db = -35.0
	music_player.play()

func play_slash() -> void:
	play_sfx(slash)

func play_swing() -> void:
	play_sfx(swing, -10)
	
func stop_music() -> void:
	music_player.stop()
	
func playBossDie() -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	
	player.stream = bossDie
	player.volume_db = -10
	player.bus = "SFX"
	
	add_child(player)
	
	player.finished.connect(player.queue_free)
	player.play()
	return player
	
func playSlam() -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	
	player.stream = slam
	player.volume_db = -15
	player.bus = "SFX"
	
	add_child(player)
	
	player.finished.connect(player.queue_free)
	player.play()
	return player
	
func playWhoosh() -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	
	player.stream = whoosh
	player.volume_db = -15
	player.bus = "SFX"
	
	add_child(player)
	
	player.finished.connect(player.queue_free)
	player.play()
	return player
	
func playSplat() -> AudioStreamPlayer:
	var player := AudioStreamPlayer.new()
	
	player.stream = splat
	player.volume_db = -15
	player.bus = "SFX"
	
	add_child(player)
	
	player.finished.connect(player.queue_free)
	player.play()
	return player
	
func play_sfx(stream: AudioStream, volume : float = -30.0) -> void:
	stream.loop = false
	
	sfx_player.stream = stream
	sfx_player.volume_db = volume
	sfx_player.play()
	
func stop_sfx()->void:
	sfx_player.stop()
	
func playFootsteps() -> void:
	sfx_player.stream = steps
	sfx_player.volume_db = -10.0
	sfx_player.play()
