class_name QuestionMenu
extends MenuInstance
## Menu used for presenting simple popups.
##
## Allows for a question and several answers.

#region Functions

func open(_params: Array[Variant] = []) -> void:
	var question_label = get_node("Modulate/Position/Panel/VBox/Margin/Question")
	var answer_button = get_node("Modulate/Position/Panel/VBox/HBox/Answer")
	
	question_label.text = _params[0]
	var answers = _params[1] as Dictionary[String, Callable]
	var answers_container = answer_button.get_parent()
	var answer_buttons : Array[ButtonModified] = [answer_button]
	
	for i in range(answers.size() - 1):
		var new_answer_button = answer_button.duplicate()
		answers_container.add_child(new_answer_button)
		answer_buttons.append(new_answer_button)
	
	for i in range(answer_buttons.size()):
		answer_buttons[i].text = answers.keys()[i]
		answer_buttons[i].pressed.connect(answers.values()[i])
		answer_buttons[i].pressed.connect(close)

	super()

#endregion
