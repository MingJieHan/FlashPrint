from django.db import models
from django.utils import timezone
import datetime
from flashprint.settings import MEDIA_STATIC_PATH


import datetime
TIME_FORMAT = "%Y-%m-%d %H:%M:%S"


TASK_STATUS_CHOICES =(
    ('N', '未处理'),
    ('P', '打印中'),
    ('W', '待付费'),
    ('F', '打印失败'),
    ('C', '已完成'),
)
    
class Task(models.Model):
    create_date = models.DateTimeField('Create date',default=timezone.now)
    ip = models.CharField(max_length=200,blank=True, null = True,help_text='')
    mac = models.CharField(max_length=200,blank=True, null = True,help_text='请求设备的Mac地址')
    printed_date = models.DateTimeField('Print date', blank=True, null = True)
    image = models.FileField('Image', upload_to=MEDIA_STATIC_PATH, blank=True, null=True)
    note = models.CharField(max_length=300,blank=True, null = True,help_text='')
    status = models.CharField('Status', max_length=1, choices=TASK_STATUS_CHOICES,default='N', help_text='任务状态')
        
    def printing(self):
        if 'N' == self.status:
            #在状态为 N 情况下，准许请求者打印
            #多打印机时，此方法非常必要
            self.status = 'P';
            self.save()
            return True
        else:
            #否则，返回禁止
            return False
            
    def printed(self):
        if 'P' != self.status:
            return False
        self.status = 'C'
        self.printed_date = datetime.datetime.now()
        self.save()
        return True
    
    def failed(self):
        if 'P' != self.status:
            return False
        self.status = 'F'
        self.save()
        return True
        
    def json_encode(self, request):
        result = {}
        host = request.META['HTTP_HOST']
        if host == 'flashprint.hanmingjie.com' :
            http = 'https'
        else:
            http = 'http'
        for key in self.__dict__.keys():
            if key == '_state' or key == 'article_id':
                continue
            if isinstance (self.__dict__[key], datetime.datetime):
                result[key] = self.__dict__[key].strftime(TIME_FORMAT)
                continue
            if key == 'image':
                result[key] = http + '://' + host + '/images' + '%s' % self.__dict__[key]
                continue
            if self.__dict__[key]:
                result[key] = self.__dict__[key]
        return result
