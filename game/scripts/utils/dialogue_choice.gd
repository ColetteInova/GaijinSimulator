extends Resource
class_name DialogueChoice

## Representa uma opção de escolha em um diálogo

@export var choice_text: String = ""  ## Texto da opção de escolha
@export var next_dialogue_index: int = -1  ## Índice da próxima linha após escolher (-1 = continua sequencial)
