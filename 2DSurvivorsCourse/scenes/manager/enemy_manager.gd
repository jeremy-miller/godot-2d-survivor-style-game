extends Node


const SPAWN_RADIUS = 375  # half of viewport width + buffer (so we don't ever see enemies spawn in)


@export var basic_enemy_scene: PackedScene
@export var wizard_enemy_scene: PackedScene
@export var arena_time_manager: Node


@onready var timer = $Timer


var base_spawn_time = 0
var enemy_table = WeightedTable.new()


func _ready():
	enemy_table.add_item(basic_enemy_scene, 10)
	base_spawn_time = timer.wait_time
	timer.timeout.connect(on_timer_timeout)
	arena_time_manager.arena_difficulty_increased.connect(on_arena_difficulty_increased)


func get_spawn_position():
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return Vector2.ZERO

	# raycast to check if spawn position is inside arena
	var spawn_position = Vector2.ZERO
	var random_direction = Vector2.RIGHT.rotated(randf_range(0, TAU))
	for i in 4:  # garuanteed that at least one of the four 90-degree directions from the chosen "random_direction" will be inside arena walls
		spawn_position = player.global_position + (random_direction * SPAWN_RADIUS)
		var additional_check_offset = random_direction * 20  # make sure we don't choose a spawn position so close a wall that an enemy sprite gets stuck
		var query_parameters = PhysicsRayQueryParameters2D.create(player.global_position, spawn_position + additional_check_offset, 1 << 0)  # check against "terrain" layer (bit 0 of collision mask)
		var result = get_tree().root.world_2d.direct_space_state.intersect_ray(query_parameters)
		if result.is_empty():  # no wall collisions detected, so spawn_position is inside arena walls
			break
		else:  # wall collision detected, so spawn_position is outside arena walls
			# rotate random_direction vector 90 degrees and try again
			random_direction = random_direction.rotated(deg_to_rad(90))
	return spawn_position


func on_timer_timeout():
	timer.start()
	var player = get_tree().get_first_node_in_group("player") as Node2D
	if player == null:
		return
	var enemy_scene = enemy_table.pick_item()
	var enemy = enemy_scene.instantiate() as Node2D
	var entities_layer = get_tree().get_first_node_in_group("entities_layer")
	entities_layer.add_child(enemy)
	enemy.global_position = get_spawn_position()


func on_arena_difficulty_increased(arena_difficulty: int):
	var time_off = (0.1 / 12) * arena_difficulty  # 12 5-second increments in 60 seconds
	time_off = min(time_off, 0.7)
	timer.wait_time = base_spawn_time - time_off
	
	if arena_difficulty == 6:  # 30 seconds into game
		enemy_table.add_item(wizard_enemy_scene, 20)
