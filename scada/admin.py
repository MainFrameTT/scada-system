from django.contrib import admin
from .models import Tag, TagValue, AlarmDefinition, Alarm

@admin.register(Tag)
class TagAdmin(admin.ModelAdmin):
    list_display = ['name', 'data_type', 'engineering_units', 'is_archived']
    list_filter = ['data_type', 'is_archived']
    search_fields = ['name', 'description']

@admin.register(TagValue)
class TagValueAdmin(admin.ModelAdmin):
    list_display = ['tag', 'value', 'quality', 'timestamp']
    list_filter = ['tag', 'timestamp']
    readonly_fields = ['timestamp']

@admin.register(AlarmDefinition)
class AlarmDefinitionAdmin(admin.ModelAdmin):
    list_display = ['name', 'tag', 'condition', 'trigger_value', 'severity', 'is_enabled']
    list_filter = ['severity', 'is_enabled', 'condition']
    list_editable = ['is_enabled']

@admin.register(Alarm)
class AlarmAdmin(admin.ModelAdmin):
    list_display = ['alarm_definition', 'triggered_at', 'state', 'acknowledged_by']
    list_filter = ['state', 'triggered_at']
    readonly_fields = ['triggered_at']