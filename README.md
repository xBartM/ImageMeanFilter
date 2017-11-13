# ImageMeanFilter
Mean filter for 24-bit .bmp files.
Use Makefile to compile and/or remove \*.o files (make clean).
Start program with arguments:

```
./result inFile.bmp outFile.bmp mask_size
```

Filter wraps around the image (at left/right edge the mask gets wrapped to the other side of the image).

Filter doesn't support padding (image must have it's width and height divisible by 4).
