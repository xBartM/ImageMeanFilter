#include <stdio.h>
#include <stdlib.h>
#include <iostream>

extern "C" 
{
	int func(unsigned char *tab, unsigned char *out, int width, int height, int maskSize);
}

int main(int argc, char** argv)
{ 
	FILE* f;
	unsigned char header[54];
	int width;
    int height;
    int size;
    unsigned char* data,* out;

	if (argc != 4)	// check number of parameters
	{
		std::cout << "Usage: ./result inFile.bmp outFile.bmp mask_size\n";
		return -1;
	}

	if (atoi(argv[3]) % 2 != 1)	// check if the mask has odd size
	{
		std::cout << "Mask must have odd size\n";
		return -1;
	}

	if (atoi(argv[3]) < 3)	// check if the mask is bigger than 1
	{
		std::cout << "Mask must be bigger than 1\n";
		return -1;
	} 
    
    f = fopen(argv[1], "rb"); // open file to read
    
    fread(header, sizeof(unsigned char), 54, f); // read the 54-byte header

	width = *(int*)&header[18]; // get width
	height =*(int*)&header[22]; // get height
    size = 3 * width * height; // calculate size
    data = new unsigned char[size]; // allocate 3 bytes per pixel
	out = new unsigned char[size];
    fread(data, sizeof(unsigned char), size, f); // read all BGR values
	for(int i = 0; i < size; i++) // copy data
		out[i] = data[i];
    fclose(f); // close read file

	func(data, out, width, height, atoi(argv[3]));

	f = fopen(argv[2], "wb"); // open output file to write to
    fwrite(header, sizeof(unsigned char), 54, f); // write the 54-byte header
    fwrite(out, sizeof(unsigned char), size, f); // write all BGR values
    fclose(f); // close write file
		
	delete[] data; // free allocated memory
	delete[] out;


	return 0;
}

