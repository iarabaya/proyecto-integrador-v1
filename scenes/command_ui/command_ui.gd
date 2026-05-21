extends Node

$CommandUI.run_pressed.connect(func(moves): await ProgramExecutor.execute(moves, $Player))
$CommandUI.restart_pressed.connect(_on_restart)
