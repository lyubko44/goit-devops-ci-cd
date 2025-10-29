from django.contrib import admin
from django.http import HttpResponse
from django.urls import path


def home(_request):
    return HttpResponse("Hello from Django in Docker with PostgreSQL and Nginx!")


urlpatterns = [
    path("admin/", admin.site.urls),
    path("", home, name="home"),
]


