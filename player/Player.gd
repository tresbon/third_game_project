extends RigidBody2D

# shoot signal for Bullet scene
signal shoot
# bullet scene
export (PackedScene) var Bullet
export (float) var fire_rate
var can_shoot = true

#state for FSM
var state = null
#Create constants for FSM states
enum {INIT, ALIVE, INVULNERABLE, DEAD}

#EP for physics (used on linear speed vector)
export (int) var engine_power
# value of angular speed
export (int) var spin_power
# value of linear speed
var thrust = Vector2()
# vector of angular speed
var rotation_dir = 0
# for screen whrap
var screensize = Vector2()


func _ready():
	#Change Phayer state to ALIVE
	change_state(ALIVE)
	#Set screensize to viewport
	screensize = get_viewport().get_visible_rect().size
	#Set fire_rate to timer
	$GunTimer.wait_time = fire_rate
	
	
func change_state(new_state):
	# creates and change FSM states
	match new_state:
		INIT:
			$CollisionShape2D.disabled == true
		ALIVE:
			$CollisionShape2D.disabled == false
		INVULNERABLE:
			$CollisionShape2D.disabled == true
		DEAD:
			$CollisionShape2D.disabled == true
	state = new_state
	
func _process(delta):
	get_input()
	
func get_input():
	thrust = Vector2()
	if state in [DEAD, INIT]:
		return
	if Input.is_action_pressed("thrust"):
		thrust = Vector2(engine_power, 0)
		rotation_dir = rotation_dir * 0.8
	if Input.is_action_pressed("rotate_left"):
		rotation_dir -= 1
	if Input.is_action_pressed("rotate_right"):
		rotation_dir += 1
	if Input.is_action_pressed("shoot") and can_shoot:
		shoot()
		
func shoot():
	if state == INVULNERABLE:
		return
	emit_signal('shoot', Bullet, $Muzzle.global_position, rotation)
	can_shoot = false
	$GunTimer.start()
		
func _integrate_forces(physics_state):
	set_applied_force(thrust.rotated(rotation))
	set_applied_torque(spin_power * rotation_dir)
	var xform = physics_state.get_transform()
	if xform.origin.x > screensize.x:
		xform.origin.x = 0
	if xform.origin.x < 0:
		xform.origin.x = screensize.x
	if xform.origin.y > screensize.y:
		xform.origin.y = 0
	if xform.origin.y < 0:
		xform.origin.y = screensize.y
	physics_state.set_transform(xform)

func _on_GunTimer_timeout():
    '''gives opportunity to shoot'''
	can_shoot = true
