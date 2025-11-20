from django.contrib import admin
from django.urls import path, include
from django.http import JsonResponse

def api_root(request):
    return JsonResponse({
        'message': 'SCADA System API',
        'endpoints': {
            'admin': '/admin/',
            'api_docs': '/api/',
            'tags': '/api/tags/',
            'alarms': '/api/alarms/',
            'pipeline_objects': '/api/pipeline-objects/',
        }
    })

urlpatterns = [
    path('', api_root, name='home'),
    path('admin/', admin.site.urls),
    path('api/', include('scada.urls')),
]