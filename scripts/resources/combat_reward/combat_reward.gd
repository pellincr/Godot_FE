extends Resource

class_name CombatReward

#Level Set Values
@export var par_turns := 0 #number of turns the level is set to take the average player
var units_allowed := 0 #number of units player is allowed on the level

#Player Determined Values
var turns_survived := 0 #The number of turns the player survived
var units_lost := 0 #The number of units the player has let die in the level


enum GRADE{
	D,C,B,A,NA
}
var turn_grade : GRADE
var survival_grade : GRADE
var overall_grade : GRADE

@export var base_gold := 0
@export var base_bonus_exp := 0
var reward_gold := 0
var reward_bonus_exp := 0


func grade_string(grade:GRADE) -> String:
	match grade:
		GRADE.A:
			return "A"
		GRADE.B:
			return "B"
		GRADE.C:
			return "C"
		GRADE.D:
			return "D"
		GRADE.NA:
			return "-"
	return "ERROR"


func calculate_turn_grade():
	if turns_survived <= par_turns * .8:
		turn_grade = GRADE.A
	elif turns_survived <= par_turns:
		turn_grade = GRADE.B
	elif turns_survived <= par_turns * 1.2:
		turn_grade = GRADE.C
	elif turns_survived > par_turns * 1.5:
		turn_grade = GRADE.D

func calculate_survival_grade():
	var p_loss := float(units_lost)/units_allowed * 100
	if p_loss == 0:
		survival_grade = GRADE.A
	elif 0 < p_loss and p_loss <= 15:
		survival_grade = GRADE.B
	elif 15 < p_loss and p_loss <= 30:
		survival_grade = GRADE.C
	elif 30 < p_loss:
		survival_grade = GRADE.D

func get_value_grade(value:float) -> GRADE:
	var grade : GRADE
	if value <= 1.0:
		grade = GRADE.D
	elif value <= 2.0:
		grade = GRADE.C
	elif value <= 3.0:
		grade = GRADE.B
	elif value <= 4.0:
		grade = GRADE.D
	return grade

func get_grade_value(grade:GRADE) -> float:
	match grade:
		GRADE.A:
			return 4.0
		GRADE.B:
			return 3.0
		GRADE.C:
			return 2.0
		GRADE.D:
			return 1.0
	return 0.0

func calculate_overall_grade():
	var avg_score : float
	if !turn_grade == GRADE.NA:
		#If there is a turn grade (win condition is not survive X turns)
		var turn_grade_value = get_grade_value(turn_grade)
		var survival_grade_value = get_grade_value(survival_grade)
		avg_score = (turn_grade_value + survival_grade_value)/2
	else:
		#If there is not turn grade (win condition is survive X turns)
		avg_score = get_grade_value(survival_grade)
	overall_grade = get_value_grade(avg_score)


func calculate_reward():
	var mult : float
	match overall_grade:
		GRADE.A:
			mult = 2.0
		GRADE.B:
			mult = 1.5
		GRADE.C:
			mult = 1.2
		GRADE.D:
			mult = 1.0
	reward_gold = floor(base_gold * mult)
	reward_bonus_exp = floor(base_bonus_exp * mult)
