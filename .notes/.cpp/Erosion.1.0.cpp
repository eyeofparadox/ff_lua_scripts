#include <cstdlib>
#include <iostream>
#include <fstream>
#include <string>
#include <cmath>
#include <ctime>
#include <cfloat>

using namespace std;

/*****************************************FILENAME DEFINITION***/
const char oname[16]="test.bmp";

/*******************************************STRUCT DEFINITION***/
struct color{
	//v[0]=red, v[1]=green, v[2]=blue
	unsigned char v[3];
	
	color(unsigned char r, unsigned char g, unsigned char b){
		v[0]=r;
		v[1]=g;
		v[2]=b;
	}
};

/********************************************SIZE DEFINITIONS***/
const unsigned hgrid = 350,//x dimension of the grid (can be anything >= 1)
			   vgrid = hgrid;//y dimension of the grid (can be anything >= 1 (hgrid and vgrid can differ); I only do this to make a square image)

/*********************************************SEED DEFINITION***/
int permutations[256];

/*****************************************FUNCTION PROTOTYPES***/
int random(int x, int y);
float random(int x, int y, int z);
color lerp(color c1, color c2, float value);//LERP = Linear intERPolation

void fillMap(float map[][vgrid]);// make the heightmap
void erodeMap(float map[][vgrid]);//erode the heightmap
void printMap(float map[][vgrid]);//bitmap part
void printPage(time_t beginning, time_t end);//webpage part

float cellNoise(float x,float y);
float euclideanSquared(float x1, float y1, float x2, float y2);

float simplexNoise(float x, float y);
int   myfloor(float value);
float dotproduct(float grad[], float x, float y);

void thermalErosion(float map[][vgrid], int iterations);
void hydraulicErosion(float map[][vgrid], int iterations);
void improvedErosion(float map[][vgrid], int iterations);

/********************************************************MAIN***/
int main()
{
	time_t beginning = time(NULL),//these two are used to time our algorithm
		   end;

	srand((unsigned)beginning);

	int i,j,k;

	//randomize the permutations table
	for (i=0;i<256;++i)
		permutations[i]=i;

	for (i=0;i<256;++i)
	{
		j=permutations[i];
		k=rand() & 255;
		permutations[i]=permutations[k];
		permutations[k]=j;
	}


	float map[hgrid][vgrid];//make the empty array

	//make the heightmap
	fillMap(map);

	//erode the heightmap
	erodeMap(map);
	
	//now that we have an interesting map, create a .BMP file
	printMap(map);
	
	//finally, output a webpage
	end = time(NULL);//set it to now
	printPage(beginning, end);

	return (0);
}

/***************************************FUNCTION DECLARATIONS***/
color lerp(color c1, color c2, float value){
	color tcolor(0,0,0);
	
	for (int g=0;g<3;g++)
		tcolor.v[g] = (unsigned char)(float(c1.v[g]) * (1.0f-value) + float(c2.v[g]) * value);
	
	return (tcolor);
}

void fillMap(float map[][vgrid])
{
//set up some variables
	
	int	i,//iterator
		x,y,//location variables
		octaves = 5;//octaves (levels of detail or number of passes)
	
	float gain = 0.65f, //modifier for the amplitude
		  lacunarity = 2.0f, //modifier for the frequency
		  frequency,amplitude,offset, //used for calculations
		  min = FLT_MAX, max = -FLT_MAX;

//get started
	for (x=0;x<hgrid;++x)
	{
		for (y=0;y<vgrid;++y)
		{
			//for each pixel, get the value
			float totalcell = 0.0f,
				  totalsimp = 0.0f;
			frequency = 4.0f/(float)hgrid;
			amplitude = 1.0f;
			
			//some big cell noise for features...
			for (i = 0; i < 2; ++i)
			{
				offset = (float)i * 7.0f;//this is just to add variance between layers

				totalcell += cellNoise((float)x * frequency + offset, (float)y * frequency + offset) * amplitude;
				
				frequency *= lacunarity;
				amplitude *= gain;
			}

			//... and some little simplex noise for details.
			//	The change in amplitude is because cell noise is much bigger than simplex noise before being normalized
			for (amplitude *= 30.0f;i < octaves; ++i)
			{
				offset = (float)i * 7.0f;//this is just to add variance between layers

				totalsimp += simplexNoise((float)x * frequency + offset, (float)y * frequency + offset) * amplitude;
				
				frequency *= lacunarity;
				amplitude *= gain;
			}
			
			//now that we have the value, put it in
			map[x][y] = totalcell + totalsimp;

			if (map[x][y] > max)
				max = map[x][y];
			if (map[x][y] < min)
				min = map[x][y];
		}
	}

//now that we have a map, normalize it. After this step, all values will be between 0.0 and 1.0 (inclusively).
	float dif = max - min;
	for (x=0;x<hgrid;++x)
	{
		for (y=0;y<vgrid;++y)
		{
			map[x][y] = (map[x][y] - min) / dif;
		}
	}
}

float random(int x, int y, int z){
	int r1 = permutations[(x + permutations[(y + permutations[z & 255]) & 255]) & 255];

	return((float)r1/256.0f);
}

float cellNoise(float x, float y)
{
	int	int_x = (int)x,
		int_y = (int)y,
		i,j, tempx,tempy;

	float	frac_x = x - (float)int_x,
			frac_y = y - (float)int_y,
			points[3][3][2],
			temp_dis,
			distance1,distance2;
	
	//get the point inside the current square, and the point inside the 8 surrounding squares
	for (i = 0;i<3;++i)
	{
		for (j = 0; j < 3; ++j)
		{
			tempx = int_x + i - 1;
			tempy = int_y + j - 1;
			points[i][j][0] = tempx + random(tempx, tempy, 1);
			points[i][j][1] = tempy + random(tempx, tempy, 2);
		}
	}
	
	//get the distance to the closest point from x, y
	distance1 = distance2 = FLT_MAX;
	
	for (i = 0; i < 3; ++i)
	{
		for (j = 0; j < 3; ++j)
		{
			temp_dis = euclideanSquared(x,y,points[i][j][0],points[i][j][1]);
			
			if (temp_dis < distance1)
			{
				if (distance1 < distance2)
					distance2 = distance1;

				distance1 = temp_dis;
			}
			else if (temp_dis < distance2)
				distance2 = temp_dis;
		}
	}
	
	return (distance2 - distance1);
}

void printMap(float map[][vgrid])
{
//set up some variables
	
	float max = -FLT_MAX,
		  min = FLT_MAX;

	int i,j,k;
	
	for (i = 0; i < hgrid; ++i)
	{
		for (j = 0; j < vgrid; ++j)
		{
			if (map[i][j] > max)
				max = map[i][j];
			if (map[i][j] < min)
				min = map[i][j];
		}
	}

	float diff = max-min,
		  flood=0.3f,//flood level
		  mount=0.85f;//mountain level
	
	flood*=diff;
	mount*=diff;
	
	
	
	//these can be changed for interesting results
	color landlow(0,64,0),
		  landhigh(116,182,133),
		  waterlow(55,0,0),
		  waterhigh(106,53,0),
		  mountlow(147,157,167),
		  mounthigh(226,223,216),
		  black(0,0,0),white(255,255,255);

//3.0 output to file
	//3.1 Begin the file
	//3.1.1 open output file
	ofstream out;
	out.open(oname, ofstream::binary);
	if (!(out.is_open())){
		cout << "Target file opening error"<<endl;
		exit(0);
	}
	
	//3.1.2 copy the header
		//3.1.2.1 magic number
		out.put(char(66));
		out.put(char(77));
		
		//3.1.2.2 filsize/unused space
		for (i=0;i<8;i++)
			out.put(char(0));
		
		//3.1.2.3 data offset
		out.put(char(54));
		
		//3.1.2.4 unused space
		for (i=0;i<3;i++)
			out.put(char(0));
		
		//3.1.2.5 header size
		out.put(char(40));
		
		//3.1.2.6 unused space
		for (i=0;i<3;i++)
			out.put(char(0));
		
		//3.1.2.7 file width (trickier)
		out.put(char(hgrid & 255));
		out.put(char((hgrid>>8) & 255));
		out.put(char((hgrid>>16) & 255));
		out.put(char((hgrid>>24) & 255));
		
		//3.1.2.8 file height (trickier)
		out.put(char(vgrid & 255));
		out.put(char((vgrid>>8) & 255));
		out.put(char((vgrid>>16) & 255));
		out.put(char((vgrid>>24) & 255));
		
		//3.1.2.9 color planes
		out.put(char(1));
		out.put(char(0));
		
		//3.1.2.10 bit depth
		out.put(char(24));
		
		//3.1.2.11 the rest
		for (i=0;i<25;i++)
			out.put(char(0));
	
	//3.2 put in the elements of the array
	color newcolor(0,0,0);
	
	for (i=(vgrid-1);i>=0;i--)	//bitmaps start with the bottom row, and work their way up...
	{
		for (j=0;j<hgrid;j++)	//...but still go left to right
		{
			map[j][i]-=min;
			
			//if this point is below the floodline...
			if (map[j][i]<flood)
				newcolor=lerp(waterlow,waterhigh,map[j][i]/flood);
			
			//if this is above the mountain line...
			else if (map[j][i]>mount)
				newcolor=lerp(mountlow,mounthigh,(map[j][i]-mount)/(diff-mount));
			
			//if this is regular land
			else
				newcolor=lerp(landlow,landhigh,(map[j][i]-flood)/(mount-flood));
			
			//uncomment the line below to make it black 'n' white
			//newcolor = lerp(black,white,map[j][i]/diff);
			
			out.put(char(newcolor.v[0]));//blue
			out.put(char(newcolor.v[1]));//green
			out.put(char(newcolor.v[2]));//red
		}
		//round off the row
		for (k = 0; k < (hgrid & 3); k++)
			out.put(char(0));
	}
	
	//3.3 end the file
	out.close();
}

void printPage(time_t beginning, time_t end)
{
	double timeTaken = double(end-beginning);
	cout<<"Content-Type: text/html\n\n"
		<<"<html><head><title>FTG Page</title></head>\n"
		<<"<body>\n"
		<<"<h2>Fractal Terrain Generator Page</h2>\n"
		<<"<img src=\"test.bmp\" /><br />\n"
		<<"This took " << timeTaken << " seconds to create.<br />\n"
		<<"</body>\n"
		<<"</html>\n";
}

float euclideanSquared(float x1, float y1, float x2, float y2)
{
	float	dif_x = x1-x2,
			dif_y = y1-y2;

	return (dif_x * dif_x + dif_y * dif_y);
}

int myfloor(float value)
{
	return (value >= 0 ? (int)value : (int)value-1);
}

float dotproduct(float grad[], float x, float y)
{
	return (grad[0] * x + grad[1] * y);
}

const float general_skew = (sqrt(3.0f)-1.0f)*0.5f,
			general_unskew = (3.0f-sqrt(3.0f))/6.0f;

float simplexNoise(float x, float y)
{
	
	//these are all variables used only by the noise function, not the fBm part
	float disbx, disby,//distances to the three corners
		  dismx, dismy,//	b = bottom-left corner, m = middle corner, t = top-right corner
		  distx, disty,
		  noiseb,noisem,noiset,//noise contributions from the three corners
		  tempdis,
		  skew_value,unskew_value;
		  

	int cornerbx, cornerby,
		cornermx, cornermy, 
		cornertx, cornerty,
		gradb, gradm, gradt;//arrays should be used with all of these, but this is easier to read

	//set up the gradient table with 8 equally distributed angles around the unit circle
	float gradients[8][2];
	for (int i=0;i<8;++i)
	{
		gradients[i][0] = cos(0.785398163f * (float)i);// 0.785398163 is PI/4.
		gradients[i][1] = sin(0.785398163f * (float)i);
	}

	//get the bottom-left corner of the simplex in skewed space
	skew_value = (x + y) * general_skew;
	cornerbx = myfloor(x + skew_value);
	cornerby = myfloor(y + skew_value);

	//get the distance from the bottom corner in normal (simplex) space
	unskew_value = float(cornerbx + cornerby) * general_unskew;
	disbx = x - (float)cornerbx + unskew_value;
	disby = y - (float)cornerby + unskew_value;

	//get the middle corner in skewed space
	if (disbx > disby)
	{
		cornermx = 1 + cornerbx;//lower triangle
		cornermy = cornerby;
	}
	else
	{
		cornermx = cornerbx;//upper triangle
		cornermy = 1 + cornerby;
	}

	//get the top corner in skewed space
	cornertx = 1 + cornerbx;
	cornerty = 1 + cornerby;

	//get the distance from the other two corners
	dismx = disbx - float(cornermx-cornerbx) + general_unskew;
	dismy = disby - float(cornermy-cornerby) + general_unskew;

	distx = disbx - 1.0f + general_unskew + general_unskew;
	disty = disby - 1.0f + general_unskew + general_unskew;

	//get the gradients indices
	gradb = random(cornerbx, cornerby);
	gradm = random(cornermx, cornermy);
	gradt = random(cornertx, cornerty);

	//get the noise from each corner using an attenuation function
	//	first the bottom corner
	tempdis = 0.5f - disbx * disbx - disby * disby;
	if (tempdis < 0.0f)
		noiseb = 0.0f;
	else
	{
		tempdis *= tempdis;
		noiseb = tempdis * tempdis * dotproduct(gradients[gradb],disbx,disby);
	}

	//	then the middle corner
	tempdis = 0.5f - dismx * dismx - dismy * dismy;
	if (tempdis < 0.0f)
		noisem = 0.0f;
	else
	{
		tempdis *= tempdis;
		noisem = tempdis * tempdis * dotproduct(gradients[gradm],dismx,dismy);
	}

	//	last the top corner
	tempdis = 0.5f - distx * distx - disty * disty;
	if (tempdis < 0.0f)
		noiset = 0.0f;
	else
	{
		tempdis *= tempdis;
		noiset = tempdis * tempdis * dotproduct(gradients[gradt],distx,disty);
	}

	//notice that no interpolation is needed, just straight summation
	return (noiseb + noisem + noiset);
}

int random(int x, int y)
{
	return (permutations[(x + permutations[y & 255]) & 255] & 7);
}

void erodeMap(float map[][vgrid])
{
	thermalErosion(map,4);
	//hydraulicErosion(map,500);
	//improvedErosion(map,50);
}

void thermalErosion(float map[][vgrid], int iterations)
{
	int x,y,i,j,iter_count,
		lowest_x, lowest_y;

	float talus = 4.0f / (float)hgrid,
		  current_difference, current_height,
		  max_dif,
		  new_height;

	//for each iteration...
	for (iter_count = 0; iter_count < iterations; ++iter_count)
	{
		//for each pixel...
		for (x = 1; x < (hgrid-1); ++x)
		{
			for (y = 1; y < (vgrid-1); ++y)
			{
				current_height = map[x][y];
				max_dif = -FLT_MAX;

				for (i = -1; i < 2; i += 2)
				{
					for (j = -1; j < 2; j += 2)
					{
						current_difference = current_height - map[x+i][y+j];

						if (current_difference > max_dif)
						{
							max_dif = current_difference;

							lowest_x = i;
							lowest_y = j;
						}
					}
				}

				if (max_dif > talus)
				{
					new_height = current_height - max_dif / 2.0f;

					map[x][y] = new_height;
					map[x + lowest_x][y + lowest_y] = new_height;
				}
			}
		}
	}
}

void hydraulicErosion(float map[][vgrid], int iterations)
{
	int x,y,i,j,iter_count,
		lowest_x, lowest_y;

	float water_map[hgrid][vgrid],
		  rain_amount = 0.01f, //amount of rain dropped per pixel each iteration
		  solubility = 0.01f, //how much sediment a unit of water will erode
		  evaporation = 0.9f, //how much water evaporates from each pixel each iteration
		  capacity = solubility, //how much sediment a unit of water can hold
		  water_lost,current_height,current_difference,max_dif; //temporary variables
		  
	//fill the water map with 0's
	for (i=0;i<hgrid;++i)
	{
		for (j=0;j<vgrid;++j)
			water_map[i][j] = 0.0f;
	}
		  
	//for each iteration...
	for (iter_count = 0; iter_count < iterations; ++iter_count)
	{
		//step 1: rain
		for (x = 0; x < hgrid; ++x)
		{
			for (y = 0; y < vgrid; ++y)
				water_map[x][y] += rain_amount;
		}

		//step 2: erosion
		for (x = 0; x < hgrid; ++x)
		{
			for (y = 0; y < vgrid; ++y)
			{
				map[x][y] -= water_map[x][y] * solubility;
			}
		}

		//step 3: movement
		for (x = 1; x < (hgrid-1); ++x)
		{
			
			for (y = 1; y < (vgrid-1); ++y)
			{
				//find the lowest neighbor
				current_height = map[x][y] + water_map[x][y];
				max_dif = -FLT_MAX;

				for (i = -1; i < 2; i += 1)
				{
					for (j = -1; j < 2; j += 1)
					{
						current_difference = current_height - map[x+i][y+j] - water_map[x+i][y+i];

						if (current_difference > max_dif)
						{
							max_dif = current_difference;

							lowest_x = i;
							lowest_y = j;
						}
					}
				}

				//now either do nothing, level off, or move all the water
				if (max_dif > 0.0f)
				{
					//move it all...
					if (water_map[x][y] < max_dif)
					{
						water_map[x+lowest_x][y+lowest_y] += water_map[x][y];
						water_map[x][y] = 0.0f;
					}
					//level off...
					else
					{
						water_map[x+lowest_x][y+lowest_y] += max_dif / 2.0f;
						water_map[x][y] -= max_dif / 2.0f;
					}
				}
			}
		}

		//step 4: evaporation / deposition
		for (x = 0; x < hgrid; ++x)
		{
			for (y = 0; y < vgrid; ++y)
			{
				water_lost = water_map[x][y] * evaporation;

				water_map[x][y] -= water_lost;
				map[x][y] += water_lost * capacity;
			}
		}
	}
}

void improvedErosion(float map[][vgrid], int iterations)
{
	int x,y,i,j,iter_count,
		lowest_x, lowest_y;

	float talus = 12.0f / (float)hgrid,
		  current_difference, current_height,
		  max_dif,
		  new_height;
	//for each iteration...
	for (iter_count = 0; iter_count < iterations; ++iter_count)
	{
		//for each pixel...
		for (x = 1; x < (hgrid-1); ++x)
		{
			for (y = 1; y < (vgrid-1); ++y)
			{
				current_height = map[x][y];
				max_dif = -FLT_MAX;

				for (i = -1; i < 2; i += 1)
				{
					for (j = -1; j < 2; j += 1)
					{
						current_difference = current_height - map[x+i][y+j];

						if (current_difference > max_dif)
						{
							max_dif = current_difference;

							lowest_x = i;
							lowest_y = j;
						}
					}
				}

				if (max_dif > 0.0f && max_dif <= talus)
				{
					new_height = current_height - max_dif / 2.0f;

					map[x][y] = new_height;
					map[x + lowest_x][y + lowest_y] = new_height;
				}
			}
		}
	}
}