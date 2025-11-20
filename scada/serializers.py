from rest_framework import serializers
from django.contrib.auth.models import User
from .models import ObjectType, PipelineObject, TagTemplate, Tag, TagValue, AlarmDefinition, Alarm

class UserSerializer(serializers.ModelSerializer):
    class Meta:
        model = User
        fields = ['id', 'username', 'email', 'first_name', 'last_name']

class ObjectTypeSerializer(serializers.ModelSerializer):
    class Meta:
        model = ObjectType
        fields = '__all__'

class PipelineObjectSerializer(serializers.ModelSerializer):
    object_type_name = serializers.CharField(source='object_type.name', read_only=True)
    
    class Meta:
        model = PipelineObject
        fields = '__all__'

class TagTemplateSerializer(serializers.ModelSerializer):
    object_type_name = serializers.CharField(source='object_type.name', read_only=True)
    
    class Meta:
        model = TagTemplate
        fields = '__all__'

class TagSerializer(serializers.ModelSerializer):
    pipeline_object_name = serializers.CharField(source='pipeline_object.name', read_only=True)
    object_type_name = serializers.CharField(source='pipeline_object.object_type.name', read_only=True)
    object_index = serializers.CharField(source='pipeline_object.index', read_only=True)
    km_mark = serializers.FloatField(source='pipeline_object.km_mark', read_only=True)
    current_value = serializers.SerializerMethodField()
    current_quality = serializers.SerializerMethodField()
    
    class Meta:
        model = Tag
        fields = '__all__'
    
    def get_current_value(self, obj):
        latest_value = obj.values.first()
        return latest_value.value if latest_value else 0.0
    
    def get_current_quality(self, obj):
        latest_value = obj.values.first()
        return latest_value.quality if latest_value else 0

class TagValueSerializer(serializers.ModelSerializer):
    class Meta:
        model = TagValue
        fields = '__all__'

class AlarmDefinitionSerializer(serializers.ModelSerializer):
    class Meta:
        model = AlarmDefinition
        fields = '__all__'

class AlarmSerializer(serializers.ModelSerializer):
    alarm_definition_name = serializers.CharField(source='alarm_definition.name', read_only=True)
    tag_name = serializers.CharField(source='alarm_definition.tag.name', read_only=True)
    
    class Meta:
        model = Alarm
        fields = '__all__'

class AlarmAcknowledgeSerializer(serializers.Serializer):
    acknowledged_by = serializers.IntegerField()