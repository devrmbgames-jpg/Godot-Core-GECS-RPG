## Marker component: resolved attributes сущности требуют пересчёта.
##
## Пустой [member stat_types] означает полный rebuild. Если список заполнен,
## S_StatRebuild может пересчитать только перечисленные stat scripts.
extends Component
class_name C_StatsDirty

var stat_types: Array[Script] = []


## Создаёт full-dirty marker при null либо partial-dirty marker для одного stat Script.
func _init(initial_stat_type: Script = null) -> void:
	if initial_stat_type != null:
		stat_types.append(initial_stat_type)


## Добавляет stat в набор dirty без дубликатов.
func mark(stat_type: Script) -> void:
	if stat_type != null and not stat_types.has(stat_type):
		stat_types.append(stat_type)


## Пустой список трактуется как требование полного rebuild.
func requests_full_rebuild() -> bool:
	return stat_types.is_empty()
