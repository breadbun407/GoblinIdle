extends Node2D

var current_hovered_item: CraftedScrapObject = null

# Set a new hovered item and clear previous one’s labels if needed
func set_hovered_item(item: CraftedScrapObject):
	if current_hovered_item and current_hovered_item != item:
		current_hovered_item.hide_labels()
	current_hovered_item = item

# Clear the current hovered item and hide its labels
func clear_hovered_item():
	if current_hovered_item:
		current_hovered_item.hide_labels()
		current_hovered_item = null
