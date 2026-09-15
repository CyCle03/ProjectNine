class_name Player
extends RefCounted

const ATTRIBUTE_MIN := 1
const ATTRIBUTE_MAX := 100

var id: String
var player_name: String
var grade: int
var primary_position: String
var bats: String
var throws: String
var condition: int
var fatigue: int
var potential: int
var growth_rate: float
var contact: int
var power: int
var eye: int
var speed: int
var fielding: int
var arm: int
var velocity: int
var stuff: int
var control: int
var breaking: int
var stamina: int


func _init(data: Dictionary = {}) -> void:
	id = str(data.get("id", ""))
	player_name = str(data.get("player_name", "이름 없음"))
	grade = clampi(int(data.get("grade", 1)), 1, 3)
	primary_position = str(data.get("primary_position", "P"))
	bats = str(data.get("bats", "R"))
	throws = str(data.get("throws", "R"))
	condition = _attribute(data.get("condition", 70))
	fatigue = clampi(int(data.get("fatigue", 0)), 0, 100)
	potential = _attribute(data.get("potential", 50))
	growth_rate = clampf(float(data.get("growth_rate", 1.0)), 0.1, 3.0)
	contact = _attribute(data.get("contact", 50))
	power = _attribute(data.get("power", 50))
	eye = _attribute(data.get("eye", 50))
	speed = _attribute(data.get("speed", 50))
	fielding = _attribute(data.get("fielding", 50))
	arm = _attribute(data.get("arm", 50))
	velocity = _attribute(data.get("velocity", 50))
	stuff = _attribute(data.get("stuff", 50))
	control = _attribute(data.get("control", 50))
	breaking = _attribute(data.get("breaking", 50))
	stamina = _attribute(data.get("stamina", 50))


func is_pitcher() -> bool:
	return primary_position == "P"


func overall() -> int:
	if is_pitcher():
		return roundi((velocity + stuff + control + breaking + stamina) / 5.0)
	return roundi((contact + power + eye + speed + fielding + arm) / 6.0)


func to_dict() -> Dictionary:
	return {"id": id, "player_name": player_name, "grade": grade, "primary_position": primary_position, "bats": bats, "throws": throws, "condition": condition, "fatigue": fatigue, "potential": potential, "growth_rate": growth_rate, "contact": contact, "power": power, "eye": eye, "speed": speed, "fielding": fielding, "arm": arm, "velocity": velocity, "stuff": stuff, "control": control, "breaking": breaking, "stamina": stamina}


func _attribute(value: Variant) -> int:
	return clampi(int(value), ATTRIBUTE_MIN, ATTRIBUTE_MAX)

