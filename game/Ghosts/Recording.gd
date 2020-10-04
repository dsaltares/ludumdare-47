class_name Recording

var transforms := []
var killed_at_end := false

func record(transform : Transform) -> void:
	transforms.append(transform)
