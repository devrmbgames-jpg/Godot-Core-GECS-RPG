## Runtime inventory refs владельца.
##
## Ссылки намеренно не являются exact-target relationships: inventory cardinality
## высока, а основные queries не фильтруют actor по конкретной item instance.
extends Component
class_name C_Inventory

var items: Array[Entity] = []


## Добавляет уникальную non-null runtime Item Entity в inventory refs.
func add(item: Entity) -> void:
	if item != null and not items.has(item):
		items.append(item)


## Удаляет runtime Item Entity из inventory refs; отсутствие item является no-op.
func remove(item: Entity) -> void:
	items.erase(item)
