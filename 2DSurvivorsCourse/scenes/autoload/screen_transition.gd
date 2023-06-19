extends CanvasLayer


signal transition_halfway


func transition():
	$AnimationPlayer.play("in")
	await transition_halfway
	$AnimationPlayer.play("out")


func transition_to_scene(scene_path: String):
	transition()
	await transition_halfway
	get_tree().change_scene_to_file(scene_path)


func emit_transitioned_halfway():
	transition_halfway.emit()
