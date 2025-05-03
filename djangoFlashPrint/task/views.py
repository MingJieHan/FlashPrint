from django.shortcuts import render
from django.http import HttpResponse
from django.views.decorators.csrf import csrf_exempt
import time
import os
import json

from .models import Task
from flashprint.settings import MEDIA_ROOT, MEDIA_STATIC_PATH

@csrf_exempt
def index(request):
    if request.method == 'POST':
        stream = request.FILES.get('image')
        if stream:
            task = Task.objects.create()
            path = time.strftime('/%Y/%m/%d',time.localtime())
            diskpath = MEDIA_ROOT + path
            if not os.path.exists(diskpath):
                os.makedirs(diskpath)
            source = path + time.strftime('/%H%M%s',time.localtime()) + str(task.id) + stream.name
            diskSource = MEDIA_ROOT + source
            fo = open(diskSource, "wb")
            if None == fo:
                print ('Open file failed:' + diskSource)
            fo.write(stream.read())
            fo.close()
            task.image = source
        else:
            return HttpResponse('image field NOT FOUND')
            
        note = request.POST.get('note')
        if note :
            task.note = note
        else:
            print('note field NOT FOUND.')
        
        x_forwarded_for = request.META.get('HTTP_X_FORWARDED_FOR')
        if x_forwarded_for:
            ip = x_forwarded_for.split(',')[0]
        else:
            ip = request.META.get('REMOTE_ADDR')
        task.ip = ip
        task.save()
        
        #check number of task from this ip today.
        existTasksWithSamedIP = Task.objects.filter(ip=ip)
        if len(existTasksWithSamedIP) > 1:
            #超出免费范围，要收费
            task.status = 'W'
            task.save()
            return HttpResponse('您的设备已经打印过照片了，我们暂时不能为您打印，请联系管理员。')
        else:
            return HttpResponse('收到了打印照片任务， 请在打印机处稍后...')
    else:
#        return HttpResponse('图片上传界面')
        context = {}
        return render(request, 'task/index.html', context)


def tasks_printer(request):
    numPerPage = 10
    result = {}
    tasks = Task.objects.filter(status='N').order_by('create_date')
    if len(tasks) > numPerPage:
        tasks = tasks[:numPerPage]

    result['tasks'] = []
    for task in tasks:
        result['tasks'].append(task.json_encode(request))
    return HttpResponse(json.dumps(result))


#客户端请求打印这个任务，可以打印返回200 OK， 否则为错误
#GET 请求 必须参数 task_id
def let_printing(request):
    task_id = request.GET.get('task_id')
    if None == task_id:
        return HttpResponse('task_id NOT FOUND')
    task = Task.objects.get(pk=task_id)
    if None == task:
        return HttpResponse('task NOT FOUND')
    allow = task.printing()
    if not allow:
        print ('not allow')
        return HttpResponse('request task is NOT Normal status, so printing NOT allow.')
    else:
        return HttpResponse('OK')

#客户端发起，设置任务打印完成
#GET 请求 必须参数 task_id
def let_printed(request):
    task_id = request.GET.get('task_id')
    if None == task_id:
        return HttpResponse('task_id NOT FOUND')
    task = Task.objects.get(pk=task_id)
    if None == task:
        return HttpResponse('task NOT FOUND')
    allow = task.printed()
    if allow:
        return HttpResponse('OK')
    else:
        return HttpResponse('task is NOT printing status.')

#客户端发起，设置打印任务失败
#GET 请求 必须参数 task_id
def let_failed(request):
    task_id = request.GET.get('task_id')
    if None == task_id:
        return HttpResponse('task_id NOT FOUND')
    task = Task.objects.get(pk=task_id)
    if None == task:
        return HttpResponse('task NOT FOUND')
    allow = task.failed()
    if allow:
        return HttpResponse('OK')
    else:
        return HttpResponse('task is NOT printing status.')

