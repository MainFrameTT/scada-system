from django.contrib import admin
from .models import ObjectType, PipelineObject, TagTemplate, Tag, TagValue, AlarmDefinition, Alarm

@admin.register(ObjectType)
class ObjectTypeAdmin(admin.ModelAdmin):
    list_display = ['name', 'description']
    search_fields = ['name']
    list_per_page = 20

@admin.register(PipelineObject)
class PipelineObjectAdmin(admin.ModelAdmin):
    list_display = ['object_type', 'index', 'name', 'location', 'km_mark']
    list_filter = ['object_type', 'location']
    search_fields = ['name', 'index', 'description']
    list_per_page = 20

@admin.register(TagTemplate)
class TagTemplateAdmin(admin.ModelAdmin):
    list_display = ['object_type', 'name_template', 'data_type', 'engineering_units']
    list_filter = ['object_type', 'data_type']
    search_fields = ['name_template', 'description_template']
    list_per_page = 20

@admin.register(Tag)
class TagAdmin(admin.ModelAdmin):
    list_display = ['name', 'pipeline_object', 'data_type', 'engineering_units', 'is_archived']
    list_filter = ['pipeline_object__object_type', 'data_type', 'is_archived']
    search_fields = ['name', 'description', 'pipeline_object__name']
    list_editable = ['is_archived']
    list_per_page = 50

@admin.register(TagValue)
class TagValueAdmin(admin.ModelAdmin):
    list_display = ['tag', 'value', 'quality', 'timestamp']
    list_filter = ['tag', 'timestamp', 'quality']
    search_fields = ['tag__name']
    readonly_fields = ['timestamp']
    list_per_page = 100

@admin.register(AlarmDefinition)
class AlarmDefinitionAdmin(admin.ModelAdmin):
    list_display = ['name', 'tag', 'condition', 'trigger_value', 'severity', 'is_enabled']
    list_filter = ['severity', 'is_enabled', 'condition']
    search_fields = ['name', 'message', 'tag__name']
    list_editable = ['is_enabled']
    list_per_page = 20

@admin.register(Alarm)
class AlarmAdmin(admin.ModelAdmin):
    list_display = ['alarm_definition', 'triggered_at', 'state', 'acknowledged_by']
    list_filter = ['state', 'triggered_at', 'alarm_definition__severity']
    search_fields = ['alarm_definition__name', 'alarm_definition__message']
    readonly_fields = ['triggered_at']
    list_per_page = 50