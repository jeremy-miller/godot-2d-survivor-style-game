extends Node


signal ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary)
signal experience_vial_collected(number: float)
signal player_damaged


func emit_ability_upgrade_added(upgrade: AbilityUpgrade, current_upgrades: Dictionary):
	ability_upgrade_added.emit(upgrade, current_upgrades)


func emit_experience_vial_collected(number: float):
	experience_vial_collected.emit(number)


func emit_player_damaged():
	player_damaged.emit()
