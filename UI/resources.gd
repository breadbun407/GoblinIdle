extends Control

@onready var scrap_label: Label = %ScrapLabel
@onready var gold_label: Label = %GoldLabel
@onready var goblin_scrap_collector_label: Label = %GoblinScrapCollectorLabel
@onready var orc_scrap_crafter_label: Label = %OrcScrapCrafterLabel

var scrap: float
var gold: float
var scrap_goblins: float
var crafting_orcs: float

func _ready() -> void:
	ScrapManager.update_scrap_label.connect(on_scrap_total_updated)
	GoldManager.update_gold_label.connect(on_gold_total_updated)
	GoblinManager.update_scrap_goblins_label.connect(on_scrap_goblins_updated)
	GoblinManager.update_crafting_orcs_label.connect(on_crafting_orcs_updated)

	get_starting_resources()

func _process(delta: float) -> void:
	update_label(scrap, gold, scrap_goblins, crafting_orcs)

func on_scrap_total_updated(updated_scrap_total):
	scrap = updated_scrap_total

func on_gold_total_updated(updated_gold_total):
	gold = updated_gold_total

func on_scrap_goblins_updated(updated_scrap_goblins):
	scrap_goblins = updated_scrap_goblins

func on_crafting_orcs_updated(updated_crafting_orcs):
	crafting_orcs = updated_crafting_orcs


func update_label(scrap_total, gold_total, scrap_goblins_total, crafting_orcs_total):
	scrap_label.text = "Scrap: " + str(scrap_total)
	gold_label.text =  "Gold: " + str(gold_total)
	goblin_scrap_collector_label.text = "Scrap Goblins: " + str(scrap_goblins_total)
	orc_scrap_crafter_label.text = "Crafting Orcs: " + str(crafting_orcs_total)


func get_starting_resources():
	scrap = ScrapManager.scrap_total
	gold = GoldManager.gold_total
	scrap_goblins = GoblinManager.scrap_heap_goblins_current
	crafting_orcs = GoblinManager.crafting_heap_goblin_current
