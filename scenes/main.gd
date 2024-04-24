extends Node

#GAMES VARIABLES
const DINO_START_POS := Vector2i(150, 458);
const CAM_START_POS := Vector2i(576, 324);
var score : float;
var highest_score : int;
var speed : float;
const START_SPEED : float = 10.0;
const MAX_SPEED : int = 20;
var screen_size : Vector2i;
var game_running : bool;
var last_obs;
var ground_height : int;
var dificulty;
const MAX_DIFICULTY : int = 2;

#OBSTACLES
var stump = preload("res://scenes/stump.tscn");
var barrel = preload("res://scenes/barrel.tscn");
var rock = preload("res://scenes/rock.tscn");
var bird = preload("res://scenes/bird.tscn");
var floor_obstacles = [stump, barrel, rock];
var obstacles : Array;
var bird_height = [70, 390];


# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size;
	ground_height = $ground.get_node("Sprite2D").texture.get_height();
	$gameover.get_node("Button").pressed.connect(new_game);
	new_game();

func new_game():
	score = 0;
	dificulty = 0;
	
	$dino.position = DINO_START_POS;
	$dino.velocity = Vector2i(0, 0);
	$Camera2D.position = CAM_START_POS;
	$ground.position = Vector2i(0, 0);
	$dino.get_node("AnimatedSprite2D").play("idle");
	$gameover.hide();
	$HUD.get_node("StartLabel").show();
	
	get_tree().paused = false;
	for obs in obstacles:
		obs.queue_free();
	obstacles.clear();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if game_running:
		speed = START_SPEED + int(score/50);
		if speed >= MAX_SPEED:
			speed = MAX_SPEED;
		adjust_dificulty();
		
		gene_obs();
		
		$dino.position.x += speed;
		$Camera2D.position.x += speed;
		
		score += speed / 100;
		show_score();
		
		if $Camera2D.position.x - $ground.position.x > screen_size.x * 1.5:
			$ground.position.x += screen_size.x;
			
		for obs in obstacles:
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs(obs);
	else:
		$HUD.get_node("ScoreLabel").hide();
		if Input.is_action_pressed("ui_accept"):
			$HUD.get_node("ScoreLabel").show();
			$HUD.get_node("StartLabel").hide();
			game_running = true;

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE : " + str(int(score));

func gene_obs():
	var obstacle_spacing = randi_range(600, 1000);
	if (randi_range(2, 4) % 2 == 0):
		if obstacles.is_empty() or last_obs.position.x < $Camera2D.position.x + screen_size.x:
			var floor_obs = floor_obstacles[randi() % floor_obstacles.size()];
			var fobs;
			var max_obs = dificulty + 1;
			for  i in range(randi() % max_obs+1):
				fobs = floor_obs.instantiate();
				var obs_height = fobs.get_node("Sprite2D").texture.get_height();
				var obs_scale = fobs.get_node("Sprite2D").scale;
				var obs_x : int = $Camera2D.position.x + screen_size.x + obstacle_spacing - (score*0.2) + (i*100);
				var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y/2) + 5;
				add_obs(fobs, obs_x, obs_y);
				last_obs = fobs;
	else :
		if obstacles.is_empty() or last_obs.position.x < $Camera2D.position.x + screen_size.x:
			var bobs = bird.instantiate();
			var obs_x : int = $Camera2D.position.x + screen_size.x + obstacle_spacing - (score*0.2);
			var obs_y : int = bird_height[randi() % bird_height.size()];
			add_obs(bobs, obs_x, obs_y);
			last_obs = bobs;

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y);
	obs.body_entered.connect(hit_obs);
	add_child(obs);
	obstacles.append(obs);

func hit_obs(body):
	if body.name == "dino":
		game_over();
	

func adjust_dificulty():
	dificulty = int(score/200);
	if dificulty > MAX_DIFICULTY:
		dificulty = MAX_DIFICULTY;

func remove_obs(obs):
	obs.queue_free();
	obstacles.erase(obs);

func game_over():
	get_tree().paused = true;
	game_running = false;
	$gameover.show();
	
	if score > highest_score:
		highest_score = score;
		$HUD.get_node("HighestLabel").text = "HIGHEST SCORE : " + str(highest_score);
