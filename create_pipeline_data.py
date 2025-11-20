import os
import django

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'scada_backend.settings')
django.setup()

from scada.models import ObjectType, PipelineObject, TagTemplate

# Типы объектов нефтепровода
OBJECT_TYPES = [
    ('НПС', 'Нефтеперекачивающая станция'),
    ('Клапан', 'Запорная арматура'),
    ('Резервуар', 'Резервуар хранения нефти'),
    ('Насос', 'Насосный агрегат'),
    ('ДК', 'Датчик давления'),
    ('ДТ', 'Датчик температуры'),
    ('ДР', 'Датчик расхода'),
    ('ЗК', 'Задвижка камерная'),
]

# Создаем типы объектов
for type_name, type_desc in OBJECT_TYPES:
    obj_type, created = ObjectType.objects.get_or_create(
        name=type_name, 
        description=type_desc
    )
    if created:
        print(f'Создан тип: {type_name}')

# Шаблоны тегов для НПС
nps_type = ObjectType.objects.get(name='НПС')
TAG_TEMPLATES_NPS = [
    ('PRESSURE_IN_{index}', 'Давление на входе НПС {index}', 'float', 'МПа'),
    ('PRESSURE_OUT_{index}', 'Давление на выходе НПС {index}', 'float', 'МПа'),
    ('FLOW_{index}', 'Расход через НПС {index}', 'float', 'м³/ч'),
    ('TEMP_OIL_{index}', 'Температура нефти НПС {index}', 'float', '°C'),
    ('STATUS_{index}', 'Статус НПС {index}', 'boolean', ''),
]

for name_tpl, desc_tpl, data_type, units in TAG_TEMPLATES_NPS:
    TagTemplate.objects.get_or_create(
        object_type=nps_type,
        name_template=name_tpl,
        description_template=desc_tpl,
        data_type=data_type,
        engineering_units=units
    )

# Шаблоны тегов для резервуаров
tank_type = ObjectType.objects.get(name='Резервуар')
TAG_TEMPLATES_TANK = [
    ('LEVEL_{index}', 'Уровень в резервуаре {index}', 'float', 'м'),
    ('TEMP_{index}', 'Температура в резервуаре {index}', 'float', '°C'),
    ('VOLUME_{index}', 'Объем в резервуаре {index}', 'float', 'м³'),
]

for name_tpl, desc_tpl, data_type, units in TAG_TEMPLATES_TANK:
    TagTemplate.objects.get_or_create(
        object_type=tank_type,
        name_template=name_tpl,
        description_template=desc_tpl,
        data_type=data_type,
        engineering_units=units
    )

# Создаем объекты нефтепровода
PIPELINE_OBJECTS = [
    ('НПС', '001', 'НПС "Восточная"', 125.5),
    ('НПС', '002', 'НПС "Центральная"', 245.8),
    ('Резервуар', '001', 'РВС-10000 №1', 120.0),
    ('Резервуар', '002', 'РВС-15000 №2', 122.5),
    ('Насос', '001', 'Насосный агрегат ГПА-1', 126.0),
    ('Клапан', '001', 'Задвижка 1000мм', 124.8),
]

for obj_type_name, index, name, km_mark in PIPELINE_OBJECTS:
    obj_type = ObjectType.objects.get(name=obj_type_name)
    pipeline_obj, created = PipelineObject.objects.get_or_create(
        object_type=obj_type,
        index=index,
        defaults={
            'name': name,
            'km_mark': km_mark,
            'location': f'Километр {km_mark}'
        }
    )
    if created:
        print(f'Создан объект: {name}')

print("Нефтепроводная система создана!")