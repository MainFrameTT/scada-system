from rest_framework import viewsets, status
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.permissions import IsAuthenticated
from django.utils import timezone
from .models import ObjectType, PipelineObject, TagTemplate, Tag, TagValue, AlarmDefinition, Alarm
from .serializers import (
    ObjectTypeSerializer, PipelineObjectSerializer, TagTemplateSerializer,
    TagSerializer, TagValueSerializer, AlarmDefinitionSerializer, AlarmSerializer,
    AlarmAcknowledgeSerializer
)

class ObjectTypeViewSet(viewsets.ModelViewSet):
    queryset = ObjectType.objects.all()
    serializer_class = ObjectTypeSerializer
    permission_classes = [IsAuthenticated]

class PipelineObjectViewSet(viewsets.ModelViewSet):
    queryset = PipelineObject.objects.all()
    serializer_class = PipelineObjectSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        queryset = super().get_queryset()
        object_type = self.request.query_params.get('object_type')
        if object_type:
            queryset = queryset.filter(object_type_id=object_type)
        return queryset

class TagTemplateViewSet(viewsets.ModelViewSet):
    queryset = TagTemplate.objects.all()
    serializer_class = TagTemplateSerializer
    permission_classes = [IsAuthenticated]

class TagViewSet(viewsets.ModelViewSet):
    queryset = Tag.objects.filter(is_archived=False)
    serializer_class = TagSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        queryset = super().get_queryset()
        pipeline_object = self.request.query_params.get('pipeline_object')
        object_type = self.request.query_params.get('object_type')
        
        if pipeline_object:
            queryset = queryset.filter(pipeline_object_id=pipeline_object)
        if object_type:
            queryset = queryset.filter(pipeline_object__object_type_id=object_type)
        
        return queryset

class TagValueViewSet(viewsets.ModelViewSet):
    queryset = TagValue.objects.all()
    serializer_class = TagValueSerializer
    permission_classes = [IsAuthenticated]
    
    def get_queryset(self):
        queryset = super().get_queryset()
        tag_id = self.request.query_params.get('tag_id')
        if tag_id:
            queryset = queryset.filter(tag_id=tag_id)
        return queryset.order_by('-timestamp')

class AlarmDefinitionViewSet(viewsets.ModelViewSet):
    queryset = AlarmDefinition.objects.filter(is_enabled=True)
    serializer_class = AlarmDefinitionSerializer
    permission_classes = [IsAuthenticated]

class AlarmViewSet(viewsets.ModelViewSet):
    queryset = Alarm.objects.all()
    serializer_class = AlarmSerializer
    permission_classes = [IsAuthenticated]
    
    @action(detail=False, methods=['get'])
    def active(self, request):
        active_alarms = self.queryset.filter(state='ACTIVE')
        serializer = self.get_serializer(active_alarms, many=True)
        return Response({
            'items': serializer.data,
            'total': active_alarms.count()
        })
    
    @action(detail=True, methods=['post'])
    def acknowledge(self, request, pk=None):
        alarm = self.get_object()
        serializer = AlarmAcknowledgeSerializer(data=request.data)
        
        if serializer.is_valid():
            alarm.state = 'ACKNOWLEDGED'
            alarm.acknowledged_at = timezone.now()
            alarm.acknowledged_by_id = serializer.validated_data['acknowledged_by']
            alarm.save()
            
            return Response({
                'id': alarm.id,
                'message': 'Авария квитирована',
                'acknowledged_at': alarm.acknowledged_at,
                'state': alarm.state
            })
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)