extends CharacterBody2D

const GRAVITY : int = 4200;
const JUMP_SPEED : int = -1800;

func _physics_process(delta):
	velocity.y += GRAVITY * delta;
	if is_on_floor():
		$RunCol.disabled = false;
		if Input.is_action_pressed("w"):
			velocity.y += JUMP_SPEED;
			$JumpSound.play();
			$AnimatedSprite2D.play("jump");
		elif Input.is_action_pressed("s"):
			$AnimatedSprite2D.play("duck");
			$RunCol.disabled = true;
		else :
			$AnimatedSprite2D.play("run");
	elif Input.is_action_pressed("s"):
		velocity.y += 1000;
		$AnimatedSprite2D.play("duck");
		$RunCol.disabled = true;
	move_and_slide();
