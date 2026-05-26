# CharacterReaction.gd — Shows character emote reactions
class_name CharacterReaction
extends Control

@onready var _emote: AnimatedSprite2D = $CharacterReaction

var _flash_timer: SceneTreeTimer = null

# Call this to change the displayed emote immediately
func show_emote(emote_name: String) -> void:
	_flash_timer = null  
	if _emote.sprite_frames.has_animation(emote_name):
		_emote.play(emote_name)

# Wait for the current animation to finish, then show the next one
func show_emote_after_current(emote_name: String) -> void:
	_flash_timer = null
	if _emote.is_playing():
		await _emote.animation_finished
	if _emote.sprite_frames.has_animation(emote_name):
		_emote.play(emote_name)

# Brief flash of an emote, then return to a base emote
func flash_emote(emote_name: String, duration: float = 1.0, return_to: String = "neutral") -> void:
	if _emote.sprite_frames.has_animation(emote_name):
		_emote.play(emote_name)
	var timer := get_tree().create_timer(duration)
	_flash_timer = timer
	await timer.timeout
	if _flash_timer == timer:
		show_emote(return_to)
