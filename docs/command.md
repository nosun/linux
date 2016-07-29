## command case

### 查找 12 小时以内的图片,并拷贝到另外一个文件夹

```
find ./ -type f -cmin -720 -print | xargs -i mv {} /the/dst/path
```