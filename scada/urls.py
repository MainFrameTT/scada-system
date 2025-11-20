from django.urls import path, include
from rest_framework.routers import DefaultRouter
from . import views

router = DefaultRouter()
# Регистрируем ВСЕ ViewSets
router.register(r'object-types', views.ObjectTypeViewSet)
router.register(r'pipeline-objects', views.PipelineObjectViewSet)
router.register(r'tag-templates', views.TagTemplateViewSet)
router.register(r'tags', views.TagViewSet)
router.register(r'tag-values', views.TagValueViewSet)
router.register(r'alarm-definitions', views.AlarmDefinitionViewSet)
router.register(r'alarms', views.AlarmViewSet)

urlpatterns = [
    path('api/', include(router.urls)),
]