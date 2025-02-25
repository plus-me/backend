from django.db import models

from users.models import User
# Create your models here.


class NewsEntry(models.Model):
    id = models.BigAutoField(primary_key=True)
    title = models.CharField(max_length=128)
    content = models.TextField()
    user = models.ForeignKey(User, on_delete=models.CASCADE)
    time_created = models.DateTimeField(auto_now_add=True)
    last_modified = models.DateTimeField(auto_now=True)
    published = models.BooleanField(default=False)

    def __str__(self):
        return "{}".format(self.title)
