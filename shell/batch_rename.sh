#! /bin/bash

path='/www/image.app/upload/mark/';

cd $path;
for i in *.png;
do
mv "$i" "${i%.png}.com.png";
done
