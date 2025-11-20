import json
from channels.generic.websocket import AsyncWebsocketConsumer
from channels.db import database_sync_to_async
from .models import Tag, TagValue, Alarm

class TagConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        await self.accept()
        await self.send(json.dumps({
            'type': 'connection_established',
            'message': 'WebSocket connection established for tags'
        }))

    async def disconnect(self, close_code):
        pass

    async def receive(self, text_data):
        data = json.loads(text_data)
        
        if data.get('action') == 'subscribe_tags':
            # Здесь можно добавить логику подписки на конкретные теги
            await self.send(json.dumps({
                'type': 'subscription_confirmed',
                'message': 'Subscribed to tag updates'
            }))

    @database_sync_to_async
    def get_tag_updates(self):
        # Метод для получения обновлений тегов
        recent_tags = TagValue.objects.select_related('tag').order_by('-timestamp')[:10]
        return [
            {
                'tag_id': tag_value.tag.id,
                'tag_name': tag_value.tag.name,
                'value': tag_value.value,
                'quality': tag_value.quality,
                'timestamp': tag_value.timestamp.isoformat()
            }
            for tag_value in recent_tags
        ]

class AlarmConsumer(AsyncWebsocketConsumer):
    async def connect(self):
        await self.accept()
        await self.send(json.dumps({
            'type': 'connection_established',
            'message': 'WebSocket connection established for alarms'
        }))

    async def disconnect(self, close_code):
        pass

    async def receive(self, text_data):
        data = json.loads(text_data)
        
        if data.get('action') == 'subscribe_alarms':
            await self.send(json.dumps({
                'type': 'subscription_confirmed',
                'message': 'Subscribed to alarm updates'
            }))

    @database_sync_to_async
    def get_active_alarms(self):
        # Метод для получения активных аварий
        active_alarms = Alarm.objects.filter(
            state='ACTIVE'
        ).select_related(
            'alarm_definition__tag'
        )[:20]
        
        return [
            {
                'id': alarm.id,
                'name': alarm.alarm_definition.name,
                'message': alarm.alarm_definition.message,
                'severity': alarm.alarm_definition.severity,
                'tag_name': alarm.alarm_definition.tag.name,
                'triggered_at': alarm.triggered_at.isoformat()
            }
            for alarm in active_alarms
        ]