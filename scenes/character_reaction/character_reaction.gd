# CharacterReaction.gd — Shows character emote reactions
class_name CharacterReaction
extends Control

@onready var _emote: AnimatedSprite2D = $CharacterReaction

# Call this to change the displayed emote
func show_emote(emote_name: String) -> void:
	if _emote.sprite_frames.has_animation(emote_name):
		_emote.play(emote_name)

# Brief flash of an emote, then return to a base emote
func flash_emote(emote_name: String, duration: float = 1.0, return_to: String = "neutral") -> void:
	show_emote(emote_name)
	await get_tree().create_timer(duration).timeout
	show_emote(return_to)
