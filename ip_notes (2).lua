API Variables
	The scripts in Filter Forge can employ several global variables that let you query the value of the global Size and Variation sliders, the width and height of the working image and more. When referencing these variables from scripts, remember that Lua is case-sensitive, so the variable names must be written in uppercase, as shown in the list:

	SIZE – the value of the global Size slider. Available only to scripts that have the Makes use of the global Size setting flag turned on in their Script Settings. Measured in pixels, but can assume non-integer values.

	VARIATION – the value of the global Variation slider. Available only to scripts that have the Makes use of the global Variation setting flag turned on in their Script Settings.

	OUTPUT_WIDTH and OUTPUT_HEIGHT – width and height of the image currently loaded into Filter Forge. Measured in pixels.

	SEAMLESS_REGION_WIDTH and SEAMLESS_REGION_HEIGHT – width and height of the seamless region, i.e. the region in which the script must provide seamlessly-tiled output. Available only to scripts that have the Produces seamlessly-tiled results flag turned on in their Script Settings. Both variables are measured as a ratio to 

	SIZE. For example, if SIZE is 300 pixels and the seamless region width is 450 pixels, the SEAMLESS_REGION_WIDTH variable will assume the value of 1.5.

	SEAMLESS – the state of the global Seamless Tiling checkbox, either true or false. Available only to scripts that have the "Produces seamlessly-tiled results" flag turned on in their Script Settings.

API Functions for Referencing Custom Inputs
	Filter Forge provides functions allowing you to query values of custom inputs added to a Map Script or Curve Script component via the Input Editor. Each input type (e.g. Slider, Checkbox etc.) has a corresponding query function. For information on input types and their corresponding functions, see Referencing Inputs from Scripts.
	
