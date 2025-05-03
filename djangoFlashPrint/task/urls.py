from django.urls import path
from task.views import index, tasks_printer
from task.views import let_printing, let_printed, let_failed

urlpatterns = [
    path(r'index.html', index),
    path(r'printer_tasks.html', tasks_printer),
    path(r'printer_try_printing', let_printing),
    path(r'printer_try_printed', let_printed),
    path(r'printer_let_failed', let_failed)
]
