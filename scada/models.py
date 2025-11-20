from django.db import models
from django.contrib.auth.models import User
from django.utils import timezone

class ObjectType(models.Model):
    """Типы объектов нефтепровода"""
    name = models.CharField(max_length=100, unique=True, verbose_name='Тип объекта')
    description = models.TextField(blank=True, verbose_name='Описание')
    
    class Meta:
        verbose_name = 'Тип объекта'
        verbose_name_plural = 'Типы объектов'
    
    def __str__(self):
        return self.name

class PipelineObject(models.Model):
    """Объект нефтепроводной системы"""
    object_type = models.ForeignKey(ObjectType, on_delete=models.CASCADE, verbose_name='Тип объекта')
    name = models.CharField(max_length=100, verbose_name='Название объекта')
    index = models.CharField(max_length=50, verbose_name='Индекс объекта')
    description = models.TextField(blank=True, verbose_name='Описание')
    location = models.CharField(max_length=200, blank=True, verbose_name='Местоположение')
    km_mark = models.FloatField(null=True, blank=True, verbose_name='Километровая отметка')
    
    class Meta:
        verbose_name = 'Объект нефтепровода'
        verbose_name_plural = 'Объекты нефтепровода'
        unique_together = ['object_type', 'index']
    
    def __str__(self):
        return f"{self.object_type.name} {self.index} - {self.name}"

class TagTemplate(models.Model):
    """Шаблон тега для типа объекта нефтепровода"""
    DATA_TYPES = [
        ('float', 'Float'),
        ('integer', 'Integer'),
        ('boolean', 'Boolean'),
        ('string', 'String'),
    ]
    
    object_type = models.ForeignKey(ObjectType, on_delete=models.CASCADE, verbose_name='Тип объекта')
    name_template = models.CharField(max_length=100, verbose_name='Шаблон имени тега')
    description_template = models.TextField(verbose_name='Шаблон описания')
    data_type = models.CharField(max_length=10, choices=DATA_TYPES, default='float', verbose_name='Тип данных')
    engineering_units = models.CharField(max_length=50, blank=True, verbose_name='Единицы измерения')
    min_value = models.FloatField(default=0.0, verbose_name='Минимальное значение')
    max_value = models.FloatField(default=100.0, verbose_name='Максимальное значение')
    
    class Meta:
        verbose_name = 'Шаблон тега'
        verbose_name_plural = 'Шаблоны тегов'
        unique_together = ['object_type', 'name_template']
    
    def __str__(self):
        return f"{self.object_type.name} - {self.name_template}"

class Tag(models.Model):
    """Конкретный тег нефтепровода"""
    tag_template = models.ForeignKey(TagTemplate, on_delete=models.CASCADE, verbose_name='Шаблон тега')
    pipeline_object = models.ForeignKey(PipelineObject, on_delete=models.CASCADE, verbose_name='Объект нефтепровода')
    name = models.CharField(max_length=100, unique=True, verbose_name='Название тега')
    description = models.TextField(verbose_name='Описание')
    data_type = models.CharField(max_length=10, choices=TagTemplate.DATA_TYPES, verbose_name='Тип данных')
    engineering_units = models.CharField(max_length=50, blank=True, verbose_name='Единицы измерения')
    min_value = models.FloatField(default=0.0, verbose_name='Минимальное значение')
    max_value = models.FloatField(default=100.0, verbose_name='Максимальное значение')
    is_archived = models.BooleanField(default=False, verbose_name='В архиве')
    
    class Meta:
        verbose_name = 'Тег'
        verbose_name_plural = 'Теги'
        ordering = ['name']
    
    def save(self, *args, **kwargs):
        if not self.name:
            self.name = self.tag_template.name_template.replace('{index}', self.pipeline_object.index)
        if not self.description:
            self.description = self.tag_template.description_template.replace('{index}', self.pipeline_object.index)
        if not self.data_type:
            self.data_type = self.tag_template.data_type
        if not self.engineering_units:
            self.engineering_units = self.tag_template.engineering_units
        
        super().save(*args, **kwargs)
    
    def __str__(self):
        return self.name

class TagValue(models.Model):
    """Значения тегов нефтепровода"""
    tag = models.ForeignKey(Tag, on_delete=models.CASCADE, related_name='values', verbose_name='Тег')
    value = models.FloatField(verbose_name='Значение')
    quality = models.IntegerField(default=100, verbose_name='Качество (0-100)')
    timestamp = models.DateTimeField(default=timezone.now, verbose_name='Временная метка')
    
    class Meta:
        verbose_name = 'Значение тега'
        verbose_name_plural = 'Значения тегов'
        ordering = ['-timestamp']
    
    def __str__(self):
        return f"{self.tag.name}: {self.value}"

class AlarmDefinition(models.Model):
    """Определения аварий для нефтепровода"""
    CONDITIONS = [
        ('GT', 'Больше'),
        ('LT', 'Меньше'),
        ('EQ', 'Равно'),
        ('CHANGE', 'Изменение'),
    ]
    
    SEVERITIES = [
        ('LOW', 'Низкая'),
        ('MEDIUM', 'Средняя'),
        ('HIGH', 'Высокая'),
        ('CRITICAL', 'Критическая'),
    ]
    
    tag = models.ForeignKey(Tag, on_delete=models.CASCADE, verbose_name='Тег')
    name = models.CharField(max_length=200, verbose_name='Название аварии')
    condition = models.CharField(max_length=10, choices=CONDITIONS, verbose_name='Условие')
    trigger_value = models.FloatField(verbose_name='Пороговое значение')
    message = models.TextField(verbose_name='Сообщение аварии')
    severity = models.CharField(max_length=10, choices=SEVERITIES, default='MEDIUM', verbose_name='Важность')
    is_enabled = models.BooleanField(default=True, verbose_name='Активна')
    
    class Meta:
        verbose_name = 'Определение аварии'
        verbose_name_plural = 'Определения аварий'
    
    def __str__(self):
        return self.name

class Alarm(models.Model):
    """Аварийные события нефтепровода"""
    STATES = [
        ('ACTIVE', 'Активна'),
        ('ACKNOWLEDGED', 'Квитирована'),
        ('RESOLVED', 'Сброшена'),
    ]
    
    alarm_definition = models.ForeignKey(AlarmDefinition, on_delete=models.CASCADE, verbose_name='Определение аварии')
    triggered_at = models.DateTimeField(default=timezone.now, verbose_name='Время срабатывания')
    acknowledged_at = models.DateTimeField(null=True, blank=True, verbose_name='Время квитирования')
    resolved_at = models.DateTimeField(null=True, blank=True, verbose_name='Время сброса')
    state = models.CharField(max_length=15, choices=STATES, default='ACTIVE', verbose_name='Состояние')
    acknowledged_by = models.ForeignKey(User, on_delete=models.SET_NULL, null=True, blank=True, verbose_name='Квитировал')
    
    class Meta:
        verbose_name = 'Авария'
        verbose_name_plural = 'Аварии'
        ordering = ['-triggered_at']
    
    def __str__(self):
        return f"{self.alarm_definition.name} - {self.state}"