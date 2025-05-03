from django.contrib import admin
from django.utils.html import format_html
from urllib.parse import quote

from .models import Task


class TaskAdmin(admin.ModelAdmin):
    def preview(self, obj):
        href = '/images' + quote(str(obj.image))
        return format_html( f'<a href={href} target= "_blank" >preview</a>')

    def get_list_display(self, request):
        return ('create_date', 'status', 'ip', 'note', 'preview')
    
    def image_link(self, obj):
        href = '/images' + quote(str(obj.image))
        return format_html(f'<a href={href} target= "_blank" > <img src="{href}" style="width:200px; height:200px; object-fit:contain;" ></a>')
    image_link.short_description = 'Image'
    
    fields = ['status', 'create_date', 'printed_date', 'ip', 'note', 'image_link']
    readonly_fields = ['create_date', 'printed_date', 'ip', 'note', 'image_link']
        
    list_per_page = 10
admin.site.register(Task, TaskAdmin)
