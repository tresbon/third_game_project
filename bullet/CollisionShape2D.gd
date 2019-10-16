extends CollisionShape2D

export (int) var speed

var velocity = Vector2()

func start (pos, dir):
	position = pos
	rotation = dir
	velocity = Vector2(speed, 0).rotated(dir)

func _process(delta):
	position += velocity * delta
	