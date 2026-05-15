class_name GameState
extends Node

var deaths: int = 0

func add_death():
	deaths += 1

func get_deaths():
	return deaths
